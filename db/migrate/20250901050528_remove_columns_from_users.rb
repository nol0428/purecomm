class RemoveColumnsFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :personality, :string
    remove_column :users, :pronouns, :string
    remove_column :users, :hobbies, :string
    remove_column :users, :birthday, :date
  end
end
