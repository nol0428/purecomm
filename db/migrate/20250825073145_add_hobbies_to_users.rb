class AddHobbiesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :hobbies, :string
  end
end
