class MessagesController < ApplicationController
  before_action :set_partnership

  def index
    @messages = @partnership.messages.order(:created_at)
    @message  = @partnership.messages.new
  end

  def create
  @partnership = Partnership.find(params[:partnership_id])

  # save the user's message first (optional but nice for history)
  user_msg = @partnership.messages.create!(
    content: params.require(:message)[:content],
    user: current_user,
    author_kind: :user
  )

  system_prompt = "You are PureComm’s gentle coach. Be brief, warm, and practical."

  reply_text = Ai::Chat.call(
    system: system_prompt,
    user_text: user_msg.content
  )

  @partnership.messages.create!(
    content: reply_text,
    user: current_user,          # or `nil` if assistant isn't a user
    author_kind: :assistant
  )

  redirect_to partnership_messages_path(@partnership)
end

  private

  def set_partnership
    if params[:partnership_id].present?
      @partnership = current_user.partnerships.find(params[:partnership_id])
    else
      # Fallback if you only have one partnership or want a default
      @partnership = current_user.partnerships.first or
        raise ActiveRecord::RecordNotFound, "No partnership available"
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
