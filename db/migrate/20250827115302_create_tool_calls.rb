class CreateToolCalls < ActiveRecord::Migration[7.1]
  def change
    create_table :tool_calls do |t|
      t.references :message, null: false, foreign_key: true
      t.string :name
      t.jsonb :arguments

      t.timestamps
    end
  end
end
