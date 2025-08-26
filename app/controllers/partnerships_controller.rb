class PartnershipsController < ApplicationController
  def show
    @user = current_user
    @partnership = @user.current_partnership
  end
end
