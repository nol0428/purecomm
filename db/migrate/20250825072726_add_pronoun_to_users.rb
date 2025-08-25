class AddPronounToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :pronoun, :string
  end
end
