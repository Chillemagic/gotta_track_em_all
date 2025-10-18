class UpdateDescriptionForCollections < ActiveRecord::Migration[8.0]
  def change
    rename_column :collections, :descrption, :description
  end
end
