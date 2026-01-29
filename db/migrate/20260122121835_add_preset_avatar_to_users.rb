class AddPresetAvatarToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :preset_avatar, :string
  end
end
