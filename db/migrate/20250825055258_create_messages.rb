class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :partnership, null: false, foreign_key: true
      t.text :content
      t.string :role
      t.references :place, polymorphic: true

      t.timestamps
    end
  end
end
