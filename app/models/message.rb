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

  validates :content, length: { maximum: (ENV.fetch("AI_MAX_INPUT_CHARS", "1000").to_i) }

  # If a message has a chat but no partnership assigned yet, copy it from the chat
  before_validation :backfill_partnership_from_chat

  # Broadcast assistant replies only (so user msgs aren't double-rendered)
  # after_create_commit :broadcast_assistant_reply

  # --- small helper ---
  def assistant?
    role.to_s == "assistant"
  end
  # --------------------

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

  # Only append to the stream when this is an assistant message
  def broadcast_assistant_reply
    return unless assistant? && partnership.present?

    broadcast_append_later_to(
      [partnership, :messages],   # matches turbo_stream_from in index
      target: "messages",         # <div id="messages"> ... </div>
      partial: "messages/message",
      locals: { message: self }
    )
  end
end
