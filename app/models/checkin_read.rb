class CheckinRead < ApplicationRecord
  belongs_to :user
  belongs_to :checkin

  validates :user_id, presence: true
  validates :checkin_id, presence: true
  validates :checkin_id, uniqueness: { scope: :user_id }
end
