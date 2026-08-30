class RemoveErroneousCardReferenceFromCards < ActiveRecord::Migration[8.1]
  def up
    return unless column_exists?(:cards, :card_id)

    remove_reference :cards, :card, foreign_key: true
  end

  def down
    add_reference :cards, :card, foreign_key: true
  end
end
