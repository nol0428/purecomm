# app/jobs/ai_reply_job.rb
class AiReplyJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    user_msg   = Message.find(message_id)
    partnership = user_msg.partnership
    chat        = partnership.ensure_chat!

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

    # --- KILL SWITCH (add this block) ---
    ai_enabled = ActiveModel::Type::Boolean.new.cast(ENV.fetch("PURECOMM_AI_ENABLED", "true"))
    if !ai_enabled
      reply_text = "I’m taking a short maintenance break right now, but I’m here and ready to help again soon."
    else
      # Ask AI
      reply_text =
        begin
          Ai::Chat.call(
            system: "You are PureComm’s gentle relationship coach. Be brief, warm, practical. "\
                    "Use the context to remember names and preferences when helpful.",
            user_text: prompt_with_context
          )
        rescue => e
          Rails.logger.error("[AI ERROR] #{e.class}: #{e.message}")
          "Sorry — I had trouble responding just now. Please try again."
        end
    end
    # --- end kill switch ---
    # heroku config:set OPENAI_API_KEY=sk-your-openai-key-here -a purecomm
    # heroku config:set RUBYLLM_DEFAULT_MODEL=gpt-4o-mini -a purecomm

    # Save the assistant reply
    partnership.messages.create!(
      chat: chat,
      content: reply_text,
      author_kind: :assistant,
      role: "assistant"
    )
  end
end
