class AddErrorMessageToCards < ActiveRecord::Migration[8.1]
  def change
    add_column :cards, :error_message, :text
  end
end
