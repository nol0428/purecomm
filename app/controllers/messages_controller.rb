class MessagesController < ApplicationController
  before_action :set_partnership

  def index
    @messages = @partnership.messages.order(:created_at)
    @message  = @partnership.messages.new
  end

  def create
    chat = @partnership.ensure_chat!

    user_msg = @partnership.messages.create!(
      chat: chat,
      content: params.require(:message)[:content],
      user: current_user,
      author_kind: :user,
      role: "user"
    )

    # Build lightweight context from the last few messages
    recent = @partnership.messages
      .where(chat: chat)
      .where.not(role: "system")
      .order(:created_at)
      .last(6)

    context_lines = recent.map do |m|
      who = m.assistant? ? "Assistant" : "User"
      "#{who}: #{m.content.to_s.strip}"
    end

    prompt_with_context = <<~TEXT.strip
      Previous context (most recent first):
      #{context_lines.join("\n")}

      Current User: #{user_msg.content.to_s.strip}
    TEXT

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

    @partnership.messages.create!(
      chat: chat,
      content: reply_text,
      author_kind: :assistant,
      role: "assistant"
      # user: nil is fine if your column allows null; otherwise tie to a system/bot user
    )

    # Trim old messages (keep most recent 60 in this chat)
    max_keep = 60
    ids_to_keep = @partnership.messages.where(chat: chat).order(created_at: :desc).limit(max_keep).pluck(:id)
    @partnership.messages.where(chat: chat).where.not(id: ids_to_keep).delete_all

    redirect_to partnership_messages_path(@partnership)
  end

  private

  def set_partnership
    if params[:partnership_id].present?
      @partnership = current_user.partnerships.find(params[:partnership_id])
    else
      @partnership = current_user.partnerships.first or
        raise ActiveRecord::RecordNotFound, "No partnership available"
    end
  end
end
