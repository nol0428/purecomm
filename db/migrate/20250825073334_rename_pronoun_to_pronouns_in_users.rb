class RenamePronounToPronounsInUsers < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :pronoun, :pronouns
  end
end
