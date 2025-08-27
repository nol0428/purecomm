class AddCoachFieldsToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :kind, :integer
    add_column :messages, :mood, :string
    add_column :messages, :day, :string
    add_column :messages, :wants_to_talk, :string
    add_column :messages, :love_language, :string
    add_column :messages, :temperament, :string
    add_column :messages, :note, :text
    add_column :messages, :advice, :text
  end
end
