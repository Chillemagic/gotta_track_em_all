class RemoveStringFromUser < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :string, :string
  end
end
