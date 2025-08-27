class Message < ApplicationRecord
  # For user-authored messages we still pass user + partnership.
  # For LLM/system messages created by RubyLLM, allow nil user,
  # and auto-copy partnership from the chat.
  belongs_to :user,        optional: true
  belongs_to :partnership, optional: true
  belongs_to :place, optional: true, polymorphic: true

  # NEW: link each message to the LLM chat thread
  belongs_to :chat, optional: true

  enum author_kind: { user: 0, assistant: 1 }

  validates :content, presence: true
  validates :role, inclusion: { in: %w[user assistant system] }, allow_nil: false

  # Require a user only when the author is a human user
  validate :user_presence_for_user_messages

  # If a message has a chat but no partnership, copy it from the chat
  before_validation :backfill_partnership_from_chat

  # Enable RubyLLM persistence
  acts_as_message

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
