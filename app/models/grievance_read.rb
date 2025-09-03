class GrievanceRead < ApplicationRecord
  belongs_to :user
  belongs_to :grievance

  validates :user_id, presence: true
  validates :grievance_id, presence: true
  validates :grievance_id, uniqueness: { scope: :user_id }

  scope :read,   -> { where.not(read_at: nil) }
  scope :unread, -> { where(read_at: nil) }
end
