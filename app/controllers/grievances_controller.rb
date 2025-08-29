class GrievancesController < ApplicationController
  def index
    @user = current_user
    @grievances = @user.current_partnership.grievances.order(created_at: :desc)
  end

  def new
    @partnership = Partnership.find(params[:partnership_id])
    @grievance = Grievance.new
  end

  def create
    @grievance = Grievance.new(grievance_params)
    @grievance.partnership = Partnership.find(params[:partnership_id])
    @grievance.user = current_user
    if @grievance.save
      redirect_to grievance_path(@grievance)
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @grievance = Grievance.find(params[:id])
    session[:viewed_grievances] ||= []
    session[:viewed_grievances] |= [@grievance.id]
  end

  private

  def grievance_params
    params.require(:grievance).permit(:topic, :feeling, :situation, :intensity_scale)
  end
end
