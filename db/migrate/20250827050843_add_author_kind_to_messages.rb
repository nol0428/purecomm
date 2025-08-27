class AddAuthorKindToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :author_kind, :integer
  end
end
