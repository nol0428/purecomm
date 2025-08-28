class MessagesController < ApplicationController
  before_action :set_partnership

  def index
    @messages = @partnership.messages.order(:created_at)
    @message  = @partnership.messages.new
  end

  def create
    # 1) Ensure chat exists
    chat = @partnership.ensure_chat!

    # 2) Save the user's message
    @message = @partnership.messages.create!(
      chat: chat,
      content: params.require(:message)[:content],
      user: current_user,
      author_kind: :user,
      role: "user"
    )

    # 3) Enqueue AI reply (async) — page stays snappy, assistant will arrive via broadcast
    AiReplyJob.perform_later(@message.id)

    # 4) Trim old messages (keep 60 most recent for this chat)
    ids_to_keep = @partnership.messages.where(chat: chat).order(created_at: :desc).limit(60).pluck(:id)
    @partnership.messages.where(chat: chat).where.not(id: ids_to_keep).delete_all

    # 5) Turbo Stream or HTML fallback
    respond_to do |format|
      format.turbo_stream  # renders app/views/messages/create.turbo_stream.erb
      format.html { redirect_to partnership_messages_path(@partnership) }
    end
  rescue ActiveRecord::RecordInvalid
    @message = @partnership.messages.new # re-render form with errors
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "new_message",
          partial: "messages/form",
          locals: { partnership: @partnership, message: @message }
        ), status: :unprocessable_entity
      end
      format.html { render :index, status: :unprocessable_content }
    end
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
