class TalksController < ApplicationController
  before_action :set_partnership

  def index
    @talks = @partnership.talks.includes(:user).order(:created_at)
    @talk  = Talk.new
  end

  def create
    @talk = Talk.new(talk_params)
    @talk.user = current_user
    @talk.partnership = @partnership
    @talks = @partnership.talks.includes(:user).order(:created_at)

    if @talk.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to partnership_talks_path(@partnership) }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_talk",
            partial: "talks/form",
            locals: { partnership: @partnership, talk: @talk }
          )
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_partnership
    @partnership = Partnership.find(params[:partnership_id])
  end

  def talk_params
    params.require(:talk).permit(:content)
  end
end
