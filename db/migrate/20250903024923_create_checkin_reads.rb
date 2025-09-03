class CreateCheckinReads < ActiveRecord::Migration[7.1]
  def change
    create_table :checkin_reads do |t|
      t.references :user, null: false, foreign_key: true
      t.references :checkin, null: false, foreign_key: true
      t.datetime :read_at, null:false

      t.timestamps
    end
    add_index :checkin_reads, [:user_id, :checkin_id], unique: true
  end
end
