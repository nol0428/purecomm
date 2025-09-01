class CreateTalks < ActiveRecord::Migration[7.1]
  def change
    create_table :talks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :partnership, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
