class EnforceRoleOnMessages < ActiveRecord::Migration[7.1]
  def up
    # Backfill any remaining NULLs just in case
    execute "UPDATE messages SET role = 'user' WHERE role IS NULL"

    change_column_default :messages, :role, from: nil, to: "user"
    change_column_null :messages, :role, false
  end

  def down
    change_column_null :messages, :role, true
    change_column_default :messages, :role, from: "user", to: nil
  end
end
