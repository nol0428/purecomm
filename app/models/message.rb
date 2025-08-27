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

  enum author_kind: { user: 0, assistant: 1 }

  validates :content, presence: true
end
