# class Message < ApplicationRecord
#   belongs_to :user
#   belongs_to :partnership
#   belongs_to :place, optional: true, polymorphic: true

#   validates :content, presence: true
# end

class Message < ApplicationRecord
  belongs_to :user
  belongs_to :partnership
  belongs_to :place, optional: true, polymorphic: true

  # What type of message is this?
  enum kind: { chat: 0, coach: 1, grievance: 2, checkin: 3 }

  # Base validation
  validates :content, presence: true, unless: :coach?  # coach messages can auto-fill content from advice

  # Coach-specific validations when kind == "coach"
  with_options if: :coach? do
    validates :mood, :day, :wants_to_talk, presence: true
  end

  # Auto-generate advice (and content) for coach messages
  before_validation :generate_coach_advice, if: -> { coach? && advice.blank? }

  private

  def generate_coach_advice
    self.advice = Coach::Generator.call(
      mood: mood,
      day: day,
      wants_to_talk: wants_to_talk,
      love_language: love_language,
      temperament: temperament,
      note: note
    )
    # If you want the message body to be the advice text by default:
    self.content ||= advice
  end
end
