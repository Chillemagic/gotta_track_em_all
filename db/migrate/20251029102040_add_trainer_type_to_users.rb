class AddTrainerTypeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :trainer_type, :string
  end
end
