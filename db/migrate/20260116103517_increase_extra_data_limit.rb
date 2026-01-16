class IncreaseExtraDataLimit < ActiveRecord::Migration[7.1]
  def change
    change_column :blocks, :extra_data, :text, limit: 16777215
  end
end
