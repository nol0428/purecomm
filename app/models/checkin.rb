class Checkin < ApplicationRecord
  belongs_to :partnership
  belongs_to :user

  MOODS = ["Happy", "Fine", "Tired", "Sad", "Upset", "Anxious"]
  MY_DAY = ["Good", "Bad"]

  validates :mood, presence: true, inclusion: { in: MOODS }
  validates :my_day, presence: true, inclusion: { in: MY_DAY }
  # validates :discuss, presence: true
  # validates :nudge, presence: true
end
