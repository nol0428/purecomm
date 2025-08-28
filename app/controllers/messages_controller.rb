class MessagesController < ApplicationController
  before_action :set_partnership

  def index
    @messages = @partnership.messages.order(:created_at)
    @message  = @partnership.messages.new
  end

  def create
    chat = @partnership.ensure_chat!

    @message = @partnership.messages.create!(
      chat: chat,
      content: params.require(:message)[:content],
      user: current_user,
      author_kind: :user,
      role: "user"
    )

    # enqueue background reply
    AiReplyJob.perform_later(@message.id)

    # keep recent messages only (no system message management here)
    max_keep    = 60
    ids_to_keep = @partnership.messages.where(chat: chat).order(created_at: :desc).limit(max_keep).pluck(:id)
    @partnership.messages.where(chat: chat).where.not(id: ids_to_keep).delete_all

    respond_to do |format|
      format.turbo_stream  # renders create.turbo_stream.erb
      format.html { redirect_to partnership_messages_path(@partnership) }
    end
  rescue ActiveRecord::RecordInvalid
    @message = @partnership.messages.new
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
