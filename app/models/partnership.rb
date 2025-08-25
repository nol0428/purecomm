class Partnership < ApplicationRecord
  belongs_to :user_one, class_name: "User"
  belongs_to :user_two, class_name: "User"

  has_many :checkins, dependent: :destroy
  has_many :grievances, dependent: :destroy
  has_many :messages, dependent: :destroy
end
