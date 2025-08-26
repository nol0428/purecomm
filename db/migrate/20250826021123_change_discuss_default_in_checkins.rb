class ChangeDiscussDefaultInCheckins < ActiveRecord::Migration[7.1]
  def change
    change_column_default :checkins, :discuss, from: nil, to: false
  end
end
