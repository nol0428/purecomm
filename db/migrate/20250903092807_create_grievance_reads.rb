class CreateGrievanceReads < ActiveRecord::Migration[7.1]
  def change
    create_table :grievance_reads do |t|
      t.references :user, null: false, foreign_key: true
      t.references :grievance, null: false, foreign_key: true
      t.datetime :read_at, null: true

      t.timestamps
    end

    add_index :grievance_reads, [:user_id, :grievance_id], unique: true
    add_index :grievance_reads, :read_at
  end
end
