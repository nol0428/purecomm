# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :user,        optional: true          # bot messages can have no user
  belongs_to :partnership                           # required (DB: not null)
  belongs_to :chat,        optional: true
  belongs_to :place,       optional: true, polymorphic: true

  enum author_kind: { user: 0, assistant: 1 }

  validates :content, presence: true
  validates :role, inclusion: { in: %w[user assistant system] } # column has default, not null

  # ✅ Only show non-system messages in the chat feed
  scope :visible_to_users, -> { where.not(role: "system") }

  # Require a user only for human-authored messages
  validate :user_presence_for_user_messages

  validates :content, length: { maximum: (ENV.fetch("AI_MAX_INPUT_CHARS", "1000").to_i) }

  # If a message has a chat but no partnership assigned yet, copy it from the chat
  before_validation :backfill_partnership_from_chat

  # Broadcast assistant replies only (so user msgs aren't double-rendered)
  after_create_commit :broadcast_assistant_reply

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

  def broadcast_assistant_reply
    return unless assistant? && partnership.present?

    puts "📡 BROADCAST FIRING for message #{id}"

    messages_for_chat = partnership.messages
                                  .where(chat_id: chat_id)
                                  .visible_to_users
                                  .order(:created_at, :id)
                                  .to_a

    broadcast_replace_later_to(
      [partnership, :messages],
      target: "messages-body",         # inner container only
      partial: "messages/list",
      locals: { messages: messages_for_chat }
    )
  end
end
