class ToolCall < ApplicationRecord
  # The message that initiated this tool call (from acts_as_message)
  belongs_to :message, optional: true

  # Self-referential tree: a tool call can have a parent and children
  belongs_to :parent_tool_call,
             class_name: "ToolCall",
             foreign_key: :parent_tool_call_id,
             optional: true,
             inverse_of: :children

  has_many :children,
           class_name: "ToolCall",
           foreign_key: :parent_tool_call_id,
           dependent: :nullify,
           inverse_of: :parent_tool_call

  # The assistant message produced by this tool call (if any)
  belongs_to :result,
             class_name: "Message",
             foreign_key: :result_id,
             optional: true
end
