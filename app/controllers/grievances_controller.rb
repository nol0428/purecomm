class GrievancesController < ApplicationController
  def index
    @user = current_user
    @grievances = @user.current_partnership.grievances
  end

  def new
    @partnership = Partnership.find(params[:partnership_id])
    @grievance = Grievance.new
  end

  def show
    @grievance = Grievance.find(params[:id])
  end
end
