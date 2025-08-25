class RenameComentToCommentInCheckins < ActiveRecord::Migration[7.1]
  def change
    rename_column :checkins, :coment, :comment
  end
end
