class PartnershipsController < ApplicationController
  def show
    @user = current_user
    @partnership = @user.current_partnership
    partner_checkins = @partnership.checkins.where(user_id: @user.current_partner.id)

    @unread_count = partner_checkins.where.not(id: @user.checkin_reads.select(:checkin_id)).count

    recent_window = 7.days.ago..Time.current

    @recent_bad_days = partner_checkins.where(created_at: recent_window, mood: Checkin::BAD_MOODS).group("DATE(created_at)").count.size
  end
end
