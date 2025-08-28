# app/jobs/ai_reply_job.rb
class AiReplyJob < ApplicationJob
  queue_as :default

  def perform(user_message_id)
    user_msg     = Message.find(user_message_id)
    partnership  = user_msg.partnership
    chat         = partnership.ensure_chat!

    # Build lightweight context (last 6 non-system messages)
    recent = partnership.messages
                        .where(chat: chat)
                        .where.not(role: "system")
                        .order(:created_at)
                        .last(6)

    context_lines = recent.map { |m| "#{m.assistant? ? 'Assistant' : 'User'}: #{m.content.to_s.strip}" }

    prompt_with_context = <<~TEXT.strip
      Previous context (most recent first):
      #{context_lines.join("\n")}

      Current User: #{user_msg.content.to_s.strip}
    TEXT

    # Call your working RubyLLM service
    reply_text = Ai::Chat.call(
      system: "You are PureComm’s gentle relationship coach. Be brief, warm, practical. "\
              "Use the context to remember names and preferences when helpful.",
      user_text: prompt_with_context
    )

    # Persist assistant reply (after_create_commit in Message will broadcast via Turbo)
    partnership.messages.create!(
      chat: chat,
      content: reply_text,
      author_kind: :assistant,
      role: "assistant"
      # user: nil is fine for bot messages
    )
  rescue => e
    Rails.logger.error("[AiReplyJob] #{e.class}: #{e.message}")
  end
end
