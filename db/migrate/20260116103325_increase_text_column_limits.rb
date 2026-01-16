class IncreaseTextColumnLimits < ActiveRecord::Migration[7.1]
  def change
    change_column :transactions, :input, :text, limit: 4294967295
    change_column :logs, :data, :text, limit: 4294967295
  end
end
