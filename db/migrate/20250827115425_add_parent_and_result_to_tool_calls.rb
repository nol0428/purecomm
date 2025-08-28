class AddParentAndResultToToolCalls < ActiveRecord::Migration[7.1]
  def change
    # link a tool call to its parent tool call (for nested calls)
    add_reference :tool_calls,
                  :parent_tool_call,
                  foreign_key: { to_table: :tool_calls },
                  null: true

    # link a tool call to the message produced as its result
    add_reference :tool_calls,
                  :result,
                  foreign_key: { to_table: :messages },
                  null: true
  end
end
