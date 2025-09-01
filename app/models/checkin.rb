class Checkin < ApplicationRecord
  belongs_to :partnership
  belongs_to :user

  MOODS = ["Happy", "Fine", "Tired", "Sad", "Upset", "Anxious"]
  MY_DAY = ["Good", "Bad"]

  validates :mood, presence: true, inclusion: { in: MOODS }
  validates :my_day, presence: true, inclusion: { in: MY_DAY }

  validate :one_check_in_per_day, on: :create
  # validates :discuss, presence: true
  # validates :nudge, presence: true

  after_create_commit :broadcast_badge_refresh
  after_create_commit :broadcast_list_prepend

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

  def broadcast_list_prepend
    recipients.each do |uid|
      Turbo::StreamsChannel.broadcast_prepend_to(
        [:checkins_list, partnership.id, uid],
        target: "partner-checkins",
        partial: "checkins/card",
        locals: { checkin: self, read: false }
      )
    end
  end

  def one_check_in_per_day
    if user && user.checkins.where(created_at: Date.current.all_day).exists?
      errors.add(:base, "You can only perform one check-in per day.")
    end
  end
end
