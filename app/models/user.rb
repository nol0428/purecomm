class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :checkins, dependent: :destroy
  has_many :grievances, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :talks, dependent: :destroy
  has_many :checkin_reads, dependent: :destroy
  has_many :read_checkins, through: :checkin_reads, source: :checkin
  has_many :grievance_reads, dependent: :destroy
  has_many :read_grievances, through: :grievance_reads, source: :grievance

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

  def checkin_today(partnership)
    partnership.checkins.find_by(user: self, created_at: Date.current.all_day)
  end

  def primary_personality
    case personality
    when Hash
      # ensure string keys and numeric values
      normalized = personality.transform_keys(&:to_s).transform_values { |v| v.to_f }
      normalized.max_by { |_, v| v }&.first
    when String
      personality.presence
    else
      # Try to parse JSON stored in a string column
      begin
        parsed = JSON.parse(personality.to_s)
        if parsed.is_a?(Hash)
          parsed.transform_keys(&:to_s).transform_values { |v| v.to_f }.max_by { |_, v| v }&.first
        end
      rescue JSON::ParserError
        nil
      end
    end
  end
end
