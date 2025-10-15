class CreateCollections < ActiveRecord::Migration[8.0]
  def change
    create_table :collections do |t|
      t.string :name
      t.text :descrption
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
