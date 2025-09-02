class Talk < ApplicationRecord
  belongs_to :user
  belongs_to :partnership

  validates :content, presence: true, length: { maximum: 150, message: "must be under 150 characters"  }
end
