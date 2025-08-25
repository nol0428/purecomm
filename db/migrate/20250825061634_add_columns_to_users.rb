class AddColumnsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :username, :string
    add_reference :users, :partnership, foreign_key: true
    add_column :users, :personality, :string
    add_column :users, :love_language, :string
  end
end
