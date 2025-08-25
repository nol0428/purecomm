class Message < ApplicationRecord
  belongs_to :user
  belongs_to :partnership
  belongs_to :place, optional: true, polymorphic: true

  validates :content, presence: true
end
