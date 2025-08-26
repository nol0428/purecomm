class GrievancesController < ApplicationController
  def index
    @user = current_user
    @grievances = @user.current_partnership.grievances
  end

  def show
    @grievance = Grievance.find(params[:id])
  end
end
