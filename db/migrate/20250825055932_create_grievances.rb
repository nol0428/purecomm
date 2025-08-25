class CreateGrievances < ActiveRecord::Migration[7.1]
  def change
    create_table :grievances do |t|
      t.string :topic
      t.string :feeling
      t.text :situation
      t.integer :intensity_scale
      t.time :timing
      t.references :partnership, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
