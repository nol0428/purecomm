class RemovePartnershipIdFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_reference :users, :partnership, null: false, foreign_key: true
  end
end
