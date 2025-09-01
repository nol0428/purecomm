class Checkin < ApplicationRecord
  belongs_to :partnership
  belongs_to :user

  MOODS = ["Happy", "Fine", "Tired", "Sad", "Upset", "Anxious"]
  MY_DAY = ["Good", "Bad"]

  validates :mood, presence: true, inclusion: { in: MOODS }
  validates :my_day, presence: true, inclusion: { in: MY_DAY }
  # validates :discuss, presence: true
  # validates :nudge, presence: true

  after_create_commit :broadcast_badge_refresh

  def recipients
    ids = [partnership.user_one_id, partnership.user_two_id].compact
    ids - [user_id]
  end

  private

  def broadcast_badge_refresh
    ts = Time.current.to_i
    recipients.each do |uid|
      Turbo::StreamsChannel.broadcast_replace_to(
        [:checkin_badge, partnership.id, uid],
        target: "checkin_badge_#{uid}",
        partial: "checkins/badge_frame",
        locals: { partnership: partnership, uid: uid, ts: ts }
      )
    end
  end
end
