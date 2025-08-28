# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :user,        optional: true          # bot messages can have no user
  belongs_to :partnership                           # required (DB: not null)
  belongs_to :chat,        optional: true
  belongs_to :place,       optional: true, polymorphic: true

  enum author_kind: { user: 0, assistant: 1 }

  validates :content, presence: true
  validates :role, inclusion: { in: %w[user assistant system] } # column has default, not null

  # Require a user only for human-authored messages
  validate :user_presence_for_user_messages

  # If a message has a chat but no partnership assigned yet, copy it from the chat
  before_validation :backfill_partnership_from_chat

  private

  def user_presence_for_user_messages
    if author_kind == "user" && user_id.nil?
      errors.add(:user, "must exist for user messages")
    end
  end

  def backfill_partnership_from_chat
    if partnership_id.nil? && chat&.partnership_id
      self.partnership_id = chat.partnership_id
    end
  end
end
