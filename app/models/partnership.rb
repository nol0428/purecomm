class Partnership < ApplicationRecord
  belongs_to :user_one, class_name: "User"
  belongs_to :user_two, class_name: "User"

  has_many :checkins, dependent: :destroy
  has_many :grievances, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :talks, dependent: :destroy
  has_one :chat, dependent: :destroy

  # NEW: connect each partnership to a Chat
  has_one :chat, dependent: :destroy

  def partner_of(user)
    user_one == user ? user_two : user_one
  end

  # NEW: helper to always have a Chat ready
  def ensure_chat!
    chat || create_chat!(
      model_id: ENV.fetch("RUBYLLM_DEFAULT_MODEL", "gpt-4o-mini")
    )
  end
end
