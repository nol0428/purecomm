# # app/services/ai/chat.rb
# module Ai
#   class Chat
#     # Pass in your system prompt and the user text you want to respond to.
#     def self.call(system:, user_text:)
#       chat = RubyLLM
#                .chat
#                .with_model(ENV.fetch("RUBYLLM_DEFAULT_MODEL", "gpt-4o-mini"))
#                .with_temperature(0.7)

#       # set/replace the system instruction for this conversation
#       chat.with_instructions(system, replace: true)

#       # ask returns a RubyLLM::Message; we want the content string
#       chat.ask(user_text).content
#     end
#   end
# end
# app/services/ai/chat.rb
# frozen_string_literal: true

module Ai
  class Chat
    DEFAULT_MODEL = ENV.fetch("RUBYLLM_DEFAULT_MODEL", "gpt-4o-mini")
    DEFAULT_TEMPERATURE = 0.7

    # --- Simple one-off call (kept for backwards compatibility) ---
    # Usage:
    #   Ai::Chat.call(system: "...", user_text: "hi")
    def self.call(system:, user_text:, model: DEFAULT_MODEL, temperature: DEFAULT_TEMPERATURE)
      chat = RubyLLM.chat.with_model(model).with_temperature(temperature)
      chat.with_instructions(system, replace: true)
      chat.ask(user_text).content
    end

    # --- History-aware call (adds memory) ---
    # messages: array of { role: "system"|"user"|"assistant", content: "..." }
    # Example:
    #   Ai::Chat.with_history(messages: [
    #     { role: "system", content: "You are ..." },
    #     { role: "user", content: "My name is Alex" },
    #     { role: "assistant", content: "Nice to meet you, Alex." },
    #     { role: "user", content: "What's my name?" }
    #   ])
    def self.with_history(messages:, model: DEFAULT_MODEL, temperature: DEFAULT_TEMPERATURE)
      raise ArgumentError, "messages must be a non-empty Array" if !messages.is_a?(Array) || messages.empty?

      chat = RubyLLM.chat.with_model(model).with_temperature(temperature)

      # 1) If the first message is system, set/replace instructions with it
      idx = 0
      if messages.first[:role].to_s == "system"
        chat.with_instructions(messages.first[:content].to_s, replace: true)
        idx = 1
      end

      # 2) Add all but the last message (we will `.ask` with the last user turn)
      last_index = messages.length - 1
      prior = messages[idx...last_index] || []
      prior.each do |m|
        role = normalize_role(m[:role])
        next if role.nil? # skip unknown roles
        chat.add(role: role, content: m[:content].to_s)
      end

      # 3) Ask with the final message; if it's not a user, just continue
      last = messages[last_index]
      last_role = normalize_role(last[:role])

      if last_role == "user"
        chat.ask(last[:content].to_s).content
      else
        # If the last turn isn't user (e.g., assistant), nudge the model to continue
        chat.ask("").content
      end
    end

    # --- Helpers ---
    def self.normalize_role(role)
      r = role.to_s
      return "user" if r == "user"
      return "assistant" if r == "assistant"
      # RubyLLM supports "system" only via with_instructions; skip here
      nil
    end
    private_class_method :normalize_role
  end
end
