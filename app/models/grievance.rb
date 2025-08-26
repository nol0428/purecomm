class Grievance < ApplicationRecord
  belongs_to :partnership
  belongs_to :user

  validates :topic, presence: true
  validates :feeling, presence: true
  validates :situation, presence: true
  validates :intensity_scale, presence: true, numericality: { only_integer: true }, inclusion: { in: 0..5 }
end
