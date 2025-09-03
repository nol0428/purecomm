class MessagesController < ApplicationController
  before_action :set_partnership

  def index
    # ⬇️ Hide system messages from the feed
    @messages = @partnership.messages.visible_to_users.order(:created_at)
    @message  = @partnership.messages.new
  end

  def create
    chat = @partnership.ensure_chat!

    @message = @partnership.messages.new(
      chat:         chat,
      content:      message_params[:content],
      user:         current_user,  # ✅ required association
      author_kind:  :user,         # ✅ matches enum ["user","assistant"]
      role:         "user"         # ✅ your app logic
    )

    if @message.save
      # Enqueue background job for AI reply
      if ENV["AI_SYNC"] == "1"
        Rails.logger.info "[messages#create] AI_SYNC=1 → performing now for message_id=#{@message.id}"
        AiReplyJob.perform_now(@message.id)
      else
        Rails.logger.info "[messages#create] enqueue AiReplyJob message_id=#{@message.id}"
        AiReplyJob.perform_later(@message.id)
      end

      # Trim old messages (keep last 60)
      max_keep    = 60
      ids_to_keep = @partnership.messages.where(chat: chat).order(created_at: :desc).limit(max_keep).pluck(:id)
      @partnership.messages.where(chat: chat).where.not(id: ids_to_keep).delete_all

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to partnership_messages_path(@partnership) }
      end
    else
      # Re-render form with errors
      @message = @partnership.messages.new unless @message
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_message",
            partial: "messages/form",
            locals: { partnership: @partnership, message: @message }
          ), status: :unprocessable_entity
        end
        format.html { render :index, status: :unprocessable_entity }
      end
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

  # ✅ only allow content from the form; everything else is set server-side
  def message_params
    params.require(:message).permit(:content)
  end
end
