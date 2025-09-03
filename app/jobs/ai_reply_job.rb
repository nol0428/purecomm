# app/jobs/ai_reply_job.rb
class AiReplyJob < ApplicationJob
  queue_as :default

  # Short persona created once per chat
  DEFAULT_PERSONA_PROMPT = <<~PROMPT.freeze
    You are PureComm’s gentle relationship coach—warm, validating, and practical.
    PRIORITY: Tailor strategy to the partner’s personality (Four Temperaments).
    SECONDARY (only if it naturally fits): weave in the partner’s love language as a small touch.
    Keep replies to 1–5 sentences and end with a simple script the user can copy.
    If you detect abuse, coercion, or crisis, recommend pausing and seeking local support.
  PROMPT

  def perform(message_id)
    user_msg    = Message.find(message_id)
    partnership = user_msg.partnership
    chat        = user_msg.chat || partnership.ensure_chat!

    # Ensure a single static system message exists for this chat (local + Heroku)
    system_message = chat.messages.find_by(role: "system")
    unless system_message
      chat.messages.create!(
        chat: chat,
        role: "system",
        author_kind: :assistant,
        content: DEFAULT_PERSONA_PROMPT
      )
    end

    # Gather recent messages for context (exclude system)
    recent = partnership.messages
               .where(chat: chat)
               .where.not(role: "system")
               .order(:created_at)
               .last(6)

    context_lines = recent.map do |m|
      "#{m.assistant? ? 'Assistant' : 'User'}: #{m.content.to_s.strip}"
    end

    # Partner traits
    user    = user_msg.user
    partner = user&.current_partner

    # Personality and love language
    personality =
      if partner&.respond_to?(:personality_summary)
        partner.personality_summary.presence
      else
        partner&.primary_personality.presence
      end || "unspecified"

    love_lang = partner&.love_language.presence || "unspecified"

    # Dynamic add-on
    dynamic_addon = <<~PROMPT
      Partner’s personality (PRIMARY): #{personality}
      Partner’s love language (SECONDARY, only use if it fits): #{love_lang}

      Recent conversation:
      #{context_lines.join("\n")}

      Task: Validate the user in a short clause; give exactly ONE actionable next step driven by the personality.
      If the love language naturally supports that step, add ONE small, relevant touch (skip entirely if it doesn't fit or is unspecified).
      Optionally ask ONE gentle follow-up question.
      End with a one-sentence copyable script. Plain conversational text only (no bullets).
    PROMPT

    system_prompt = "#{DEFAULT_PERSONA_PROMPT}\n\n#{dynamic_addon}"
    prompt_with_context = user_msg.content.to_s.strip

    # Generate AI reply
    reply_text =
      if !ActiveModel::Type::Boolean.new.cast(ENV.fetch("PURECOMM_AI_ENABLED", "true"))
        "I'm taking a short maintenance break right now, but I'm here and ready to help again soon."
      else
        begin
          Rails.logger.debug { "AI Coach: partner_id=#{partner&.id}, personality=#{personality.inspect}, love_lang=#{love_lang.inspect}" }
          Rails.logger.debug { "AI Coach system prompt (condensed):\n#{system_prompt}" }

          Ai::Chat.call(system: system_prompt, user_text: prompt_with_context).to_s
        rescue => e
          Rails.logger.error("AiReplyJob error: #{e.class} - #{e.message}")
          "Sorry — I had trouble responding just now. Please try again."
        end
      end

    # Save the assistant reply (model handles broadcasting)
    partnership.messages.create!(
      chat: chat,
      content: reply_text,
      author_kind: :assistant,
      role: "assistant"
    )
  end
end
