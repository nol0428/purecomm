class CheckinsController < ApplicationController
  def new
    @checkin = Checkin.new
    @partnership = Partnership.find(params[:partnership_id])
  end

  def create
    @partnership = Partnership.find(params[:partnership_id])
    @checkin = Checkin.new(checkin_params)
    @checkin.user = current_user
    @checkin.partnership = @partnership

    if @checkin.save
      redirect_to checkin_path(@checkin)
    else
      render :new, status: :unprocessable_entity
    end
  end

def show
  @checkin = Checkin.find(params[:id])
  @partnership = @checkin.partnership
  session[:viewed_checkins] ||= []
  session[:viewed_checkins] << @checkin.id
  session[:viewed_checkins].uniq!
end

  private

  def checkin_params
  params.require(:checkin).permit(:mood, :my_day, :discuss, :comment, :nudge)
  end
end
