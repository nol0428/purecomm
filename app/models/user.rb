class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :checkins, dependent: :destroy
  has_many :grievances, dependent: :destroy
  has_many :messages, dependent: :destroy

  LOVE_LANGUAGES = ["Words of Affirmation", "Acts of Service", "Receiving Gifts", "Quality Time", "Physical Touch"]

  validates :username, presence: true, uniqueness: true
  validates :personality, presence: true
  validates :love_language, presence: true, inclusion: { in: LOVE_LANGUAGES }

  def partnerships
    Partnership.where(user_one: self).or(Partnership.where(user_two: self))
  end

  def current_partnership
    partnerships.first
  end

  def current_partner
  # User.find(current_partnership.select(:user_one_id, :user_two_id)).where.not(id: self)
  current_partnership.partner_of(self)
  end
end
