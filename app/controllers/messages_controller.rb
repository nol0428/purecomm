class MessagesController < ApplicationController
  before_action :set_partnership

  def index
    @messages = @partnership.messages.order(:created_at)
    @message  = @partnership.messages.new
  end

  # app/controllers/messages_controller.rb
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

    # 3) Context (last 6 non-system messages)
    recent = @partnership.messages
              .where(chat: chat).where.not(role: "system")
              .order(:created_at).last(6)

    context_lines = recent.map { |m| "#{m.assistant? ? 'Assistant' : 'User'}: #{m.content.to_s.strip}" }

    prompt_with_context = <<~TEXT.strip
      Previous context (most recent first):
      #{context_lines.join("\n")}

      Current User: #{@message.content.to_s.strip}
    TEXT

    # 4) AI reply (your existing service)
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

    # 5) Persist the assistant reply and keep a reference
    @assistant_message = @partnership.messages.create!(
      chat: chat,
      content: reply_text,
      author_kind: :assistant,
      role: "assistant"
      # user: nil is fine here
    )

    # 6) Trim old messages (keep 60 most recent for this chat)
    max_keep = 60
    ids_to_keep = @partnership.messages.where(chat: chat).order(created_at: :desc).limit(max_keep).pluck(:id)
    @partnership.messages.where(chat: chat).where.not(id: ids_to_keep).delete_all

    # 7) Turbo Stream or HTML fallback
    respond_to do |format|
      format.turbo_stream # renders app/views/messages/create.turbo_stream.erb
      format.html { redirect_to partnership_messages_path(@partnership) }
    end
  rescue ActiveRecord::RecordInvalid => e
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
