class AddRubyLlmColumnsToMessages < ActiveRecord::Migration[7.1]
  def change
    # Add chat_id (allow NULL first), but only if it's missing
    add_reference :messages, :chat, null: true, foreign_key: true, index: true unless column_exists?(:messages, :chat_id)

    # Only add these columns if they don't already exist
    # (role already exists on your DB, so this will safely skip it)
    add_column :messages, :role, :string unless column_exists?(:messages, :role)
    add_column :messages, :model_id, :string unless column_exists?(:messages, :model_id)
    add_column :messages, :input_tokens, :integer unless column_exists?(:messages, :input_tokens)
    add_column :messages, :output_tokens, :integer unless column_exists?(:messages, :output_tokens)
  end
end
