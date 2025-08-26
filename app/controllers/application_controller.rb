class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :personality, :love_language, :pronouns, :hobbies, :birthday])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :personality, :love_language, :pronouns, :hobbies, :birthday])
  end

  private

  def after_sign_in_path_for(resource)
    partnership_path(@user.current_partnership)
  end
end
