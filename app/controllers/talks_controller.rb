class TalksController < ApplicationController

  def index
    @partnership = Partnership.find(params[:partnership_id])
    @talks = @partnership.talks
    @talk = Talk.new
  end

  def create
    @partnership = Partnership.find(params[:partnership_id])
    @talk = Talk.new(talk_params)
    @talk.user = current_user
    @talk.partnership = @partnership
    @talks = @partnership.talks
    if @talk.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to talks_path(@partnership) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_message", partial: "form", locals: { partnership: @partnership, talk: @talk }) }
        format.html { render :index }
      end
    end
  end

  private
  def talk_params
    params.require(:talk).permit(:content)
  end
end
