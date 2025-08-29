class Grievance < ApplicationRecord
  belongs_to :partnership
  belongs_to :user

  validates :topic, presence: true
  validates :feeling, presence: true
  validates :situation, presence: true
  validates :intensity_scale, presence: true, numericality: { only_integer: true }, inclusion: { in: 0..5 }

  FEELINGS = ["Tired", "Sad", "Upset", "Anxious"]

  def recipients
    ids = [partnership.user_one_id, partnership.user_two_id].compact
    ids - [user_id] # 不给自己发
  end

  after_create_commit :broadcast_badge_refresh

  private

  def broadcast_badge_refresh
    ts = Time.current.to_i
    recipients.each do |uid|
      Turbo::StreamsChannel.broadcast_replace_to(
        [:grievance_badge, partnership.id, uid],
        target: "grievance_badge_#{uid}",
        partial: "grievances/badge_frame",
        locals: { partnership: partnership, uid: uid, ts: ts }
      )
    end
  end
end
