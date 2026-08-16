class AddDefaultToColumnName < ActiveRecord::Migration[8.1]
  def change
    change_column_default :cards, :holo_type, from: nil, to: 'Standard'
  end
end
