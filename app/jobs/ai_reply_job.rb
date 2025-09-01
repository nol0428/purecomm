# app/jobs/ai_reply_job.rb
class AiReplyJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    Rails.logger.info "[AiReplyJob] start message_id=#{message_id}"

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

    prompt_with_context = <<~TEXT.strip
      Previous context:
      #{context_lines.join("\n")}

      Current User: #{user_msg.content.to_s.strip}
    TEXT

    ai_enabled = ActiveModel::Type::Boolean.new.cast(ENV.fetch("PURECOMM_AI_ENABLED", "true"))
    reply_text =
      if !ai_enabled
        "I’m taking a short maintenance break right now, but I’m here and ready to help again soon."
      else
        begin
          Ai::Chat.call(
            system: "You are PureComm’s gentle relationship coach. Be brief, warm, practical. Use the context to remember names and preferences when helpful.",
            user_text: prompt_with_context
          )
        rescue => e
          Rails.logger.error "[AiReplyJob] error message_id=#{message_id} #{e.class}: #{e.message}"
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

    # Append to the end of the chat
    Turbo::StreamsChannel.broadcast_append_to(
      [partnership, :messages],
      target:  "messages",
      partial: "messages/message",
      locals:  { message: assistant }
    )

    Rails.logger.info "[AiReplyJob] done message_id=#{message_id}"
  end
end
