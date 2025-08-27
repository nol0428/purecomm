# app/services/ai/chat.rb
module Ai
  class Chat
    # Pass in your system prompt and the user text you want to respond to.
    def self.call(system:, user_text:)
      chat = RubyLLM
               .chat
               .with_model(ENV.fetch("RUBYLLM_DEFAULT_MODEL", "gpt-4o-mini"))
               .with_temperature(0.7)

      # set/replace the system instruction for this conversation
      chat.with_instructions(system, replace: true)

      # ask returns a RubyLLM::Message; we want the content string
      chat.ask(user_text).content
    end
  end
end
