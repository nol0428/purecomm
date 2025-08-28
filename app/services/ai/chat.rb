module Ai
  class Chat
    def self.call(system:, user_text:)
      chat = RubyLLM
               .chat
               .with_model(ENV.fetch("RUBYLLM_DEFAULT_MODEL", "gpt-4o-mini"))
               .with_temperature(0.7)

      chat.with_instructions(system, replace: true)
      chat.ask(user_text).content
    end
  end
end
