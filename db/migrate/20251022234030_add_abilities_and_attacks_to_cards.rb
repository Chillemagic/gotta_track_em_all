class AddAbilitiesAndAttacksToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :abilities, :jsonb
    add_column :cards, :attacks, :jsonb
  end
end
