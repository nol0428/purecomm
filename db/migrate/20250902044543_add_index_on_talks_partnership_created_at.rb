class AddIndexOnTalksPartnershipCreatedAt < ActiveRecord::Migration[7.1]
  def change
    add_index :talks, [:partnership_id, :created_at]
  end
end
