class Talk < ApplicationRecord
  belongs_to :user
  belongs_to :partnership

  validates :content, presence: true, length: { maximum: 150, message: "must be under 150 characters"  }

  after_create_commit :broadcast_append_to_talk

  private

  def broadcast_append_to_talk
    # return unless role.in?(["user", "assistant"])

    broadcast_append_to [partnership, :talks], target: "talks", partial: "talks/message", locals: { message: self }
  end
end
