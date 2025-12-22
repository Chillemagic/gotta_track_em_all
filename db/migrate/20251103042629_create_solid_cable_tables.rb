class CreateSolidCableTables < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_cable_messages do |t|
      t.string :channel, null: false
      t.text :data, null: false
      t.timestamps
    end

    add_index :solid_cable_messages, :channel
  end
end
