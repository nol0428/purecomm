class AddRubyLlmColumnsToMessages < ActiveRecord::Migration[7.1]
  def up
    # 1) Add chat_id + index only if missing
    add_column :messages, :chat_id, :bigint unless column_exists?(:messages, :chat_id)
    add_index  :messages, :chat_id       unless index_exists?(:messages, :chat_id)

    # 2) Add FK only if both tables exist and FK not present
    if table_exists?(:messages) && table_exists?(:chats)
      unless foreign_key_exists?(:messages, :chats) || foreign_key_exists?(:messages, column: :chat_id)
        add_foreign_key :messages, :chats, column: :chat_id
      end
    end

    # 3) Other columns (safe-guards keep it idempotent)
    add_column :messages, :role,          :string  unless column_exists?(:messages, :role)
    add_column :messages, :model_id,      :string  unless column_exists?(:messages, :model_id)
    add_column :messages, :input_tokens,  :integer unless column_exists?(:messages, :input_tokens)
    add_column :messages, :output_tokens, :integer unless column_exists?(:messages, :output_tokens)
  end

  def down
    # Revert in reverse order, but only if present
    remove_column :messages, :output_tokens if column_exists?(:messages, :output_tokens)
    remove_column :messages, :input_tokens  if column_exists?(:messages, :input_tokens)
    remove_column :messages, :model_id      if column_exists?(:messages, :model_id)
    remove_column :messages, :role          if column_exists?(:messages, :role)

    if foreign_key_exists?(:messages, :chats) || foreign_key_exists?(:messages, column: :chat_id)
      remove_foreign_key :messages, :chats
    end

    remove_index  :messages, :chat_id if index_exists?(:messages, :chat_id)
    remove_column :messages, :chat_id  if column_exists?(:messages, :chat_id)
  end
end
