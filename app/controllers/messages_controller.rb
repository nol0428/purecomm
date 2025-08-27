class MessagesController < ApplicationController
  before_action :set_partnership

  def index
    # Show all messages for this partnership, newest last
    @messages = @partnership.messages.order(:created_at)
    # Form object for a new message
    @message  = @partnership.messages.new
  end

  def create
    # 1) Ensure a chat exists for this partnership
    chat = @partnership.ensure_chat!

    # 2) Save the user's message (linked to the chat)
    user_msg = @partnership.messages.create!(
      chat: chat,
      content: params.require(:message)[:content],
      user: current_user,
      author_kind: :user,
      role: "user"
    )

    # 3) Lightweight memory: include the last 12 non-system messages as context (oldest -> newest)
    history_pairs = @partnership.messages
      .where(chat: chat)
      .where.not(role: "system")
      .order(:created_at)
      .last(12)
      .map do |m|
        speaker = (m.author_kind&.to_sym == :assistant) ? "Assistant" : "User"
        "#{speaker}: #{m.content.to_s.strip}"
      end

    system_with_history = <<~SYS
      You are PureComm’s gentle relationship coach. Be brief, warm, and practical.
      Use and remember details shared in THIS conversation (e.g., names, preferences).

      Conversation so far:
      #{history_pairs.join("\n")}

      When you reply, be concise and helpful.
    SYS

    # 4) Ask the model with contextualized system prompt
    reply_text =
      begin
        Ai::Chat.call(
          system:   system_with_history,
          user_text: user_msg.content.to_s
        )
      rescue => e
        Rails.logger.error("[AI ERROR] #{e.class}: #{e.message}")
        "Sorry — I had trouble responding just now. Please try again."
      end

    # 5) Save the assistant reply so it shows in the UI
    @partnership.messages.create!(
      chat: chat,
      content: reply_text.to_s,
      author_kind: :assistant,
      role: "assistant"
      # user: nil is OK if assistant messages aren't tied to a user
    )

    # 6) Trim old messages for this chat (keep most recent 60 total)
    max_keep = 60
    ids_to_keep = @partnership.messages.where(chat: chat).order(created_at: :desc).limit(max_keep).pluck(:id)
    @partnership.messages.where(chat: chat).where.not(id: ids_to_keep).delete_all

    # 7) Back to the chat page
    redirect_to partnership_messages_path(@partnership)
  end

  private

  def set_partnership
    if params[:partnership_id].present?
      # Find the partnership that belongs to the current_user
      @partnership = current_user.partnerships.find(params[:partnership_id])
    else
      # Fallback if user only has one partnership or none
      @partnership = current_user.partnerships.first or
        raise ActiveRecord::RecordNotFound, "No partnership available"
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
