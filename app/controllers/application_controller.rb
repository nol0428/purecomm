class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :personality, :love_language, :pronouns, :hobbies, :birthday])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :personality, :love_language, :pronouns, :hobbies, :birthday])
  end

  helper_method :viewed_grievance_ids_key, :viewed_grievance_ids, :mark_grievance_viewed!

  def viewed_grievance_ids_key(partnership)
    "viewed_grievances_p#{partnership.id}_u#{current_user&.id}"
  end

  def viewed_grievance_ids(partnership)
    session[viewed_grievance_ids_key(partnership)] ||= []
  end

  def mark_grievance_viewed!(grievance)
    key = viewed_grievance_ids_key(grievance.partnership)
    session[key] = (session[key] || []) | [grievance.id]
  end

  helper_method :viewed_checkin_ids, :mark_checkin_viewed!

  def viewed_checkin_ids_key(partnership)
    "viewed_checkins_p#{partnership.id}_u#{current_user&.id}"
  end

  def viewed_checkin_ids(partnership)
    session[viewed_checkin_ids_key(partnership)] ||= []
  end

  def mark_checkin_viewed!(checkin)
    key = viewed_checkin_ids_key(checkin.partnership)
    session[key] = (session[key] || []) | [checkin.id]
  end

  private

  def after_sign_in_path_for(resource)
    partnership_path(current_user.current_partnership)
  end
end
