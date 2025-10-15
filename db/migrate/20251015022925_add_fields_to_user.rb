class AddFieldsToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :username, :string
    add_column :users, :trainer_type, :string
    add_column :users, :string, :string
  end
end
