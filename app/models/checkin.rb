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

  private

  def one_check_in_per_day
    if user && user.checkins.where(created_at: Date.current.all_day).exists?
      errors.add(:base, "You can only perform one check-in per day.")
    end
  end
end
