class AddPersonalityToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :personality, :jsonb, default: {}
  end
end
