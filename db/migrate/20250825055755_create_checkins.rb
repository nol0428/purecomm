class CreateCheckins < ActiveRecord::Migration[7.1]
  def change
    create_table :checkins do |t|
      t.string :mood
      t.string :my_day
      t.boolean :discuss
      t.text :coment
      t.references :partnership, null: false, foreign_key: true
      t.time :nudge
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
