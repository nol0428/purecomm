class Ai::Chat
  def self.call(messages:, model: nil, temperature: 0.7, max_tokens: 512)
    RubyLLM.chat(
      messages: messages,
      model: model,
      temperature: temperature,
      max_tokens: max_tokens
    ).content
  end
end
