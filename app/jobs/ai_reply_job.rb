# app/jobs/ai_reply_job.rb
class AiReplyJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    user_msg    = Message.find(message_id)
    partnership = user_msg.partnership
    chat        = user_msg.chat || partnership.ensure_chat!

    # Gather recent messages for context
    recent = partnership.messages
              .where(chat: chat)
              .where.not(role: "system")
              .order(:created_at)
              .last(6)

    context_lines = recent.map { |m| "#{m.assistant? ? 'Assistant' : 'User'}: #{m.content.to_s.strip}" }

    # Partner traits
    user     = user_msg.user
    partner  = user&.current_partner
    love_lang   = partner&.love_language.presence || "not specified"
    personality = partner&.personality.presence   || "unspecified"

    # === Build full structured system prompt ===
    system_prompt = <<~PROMPT
      Persona:
      You are PureComm’s gentle relationship coach. You are warm, supportive, brief, and practical.

      Context:
      Partner’s love language: #{love_lang}
      Partner’s personality: #{personality}
      Recent messages:
      #{context_lines.join("\n")}

      Task:
      Read the user’s current message and provide a reply that supports communication,
      resolves friction gently, and offers practical suggestions when appropriate.

      Format:
      Write your reply as plain conversational text (no lists unless asked).
      Keep it concise (1–3 sentences).
    PROMPT

    # User’s current message
    prompt_with_context = user_msg.content.to_s.strip

    ai_enabled = ActiveModel::Type::Boolean.new.cast(ENV.fetch("PURECOMM_AI_ENABLED", "true"))
    reply_text =
      if !ai_enabled
        "I’m taking a short maintenance break right now, but I’m here and ready to help again soon."
      else
        begin
          Ai::Chat.call(
            system:    system_prompt,
            user_text: prompt_with_context
          ).to_s
        rescue => e
          "Sorry — I had trouble responding just now. Please try again."
        end
      end

    # Save the assistant reply
    assistant = partnership.messages.create!(
      chat: chat,
      content: reply_text,
      author_kind: :assistant,
      role: "assistant"
    )

    # Append to chat
    Turbo::StreamsChannel.broadcast_append_to(
      [partnership, :messages],
      target:  "messages",
      partial: "messages/message",
      locals:  { message: assistant }
    )
  end
end
