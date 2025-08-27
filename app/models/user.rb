class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :checkins, dependent: :destroy
  has_many :grievances, dependent: :destroy
  has_many :messages, dependent: :destroy

  PRONOUNS = ["He/Him", "She/Her", "They/Them"]

  validates :username, presence: true, uniqueness: true
  validates :personality, presence: true
  validates :love_language, presence: true
  validates :pronouns, presence: true, inclusion: { in: PRONOUNS }
  validates :birthday, presence: true

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
