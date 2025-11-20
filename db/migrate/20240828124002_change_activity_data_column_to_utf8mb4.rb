class ChangeActivityDataColumnToUtf8mb4 < ActiveRecord::Migration[5.2]
  def up
    change_column :activities, :data, :text, collation: 'utf8mb4_unicode_ci'
  end

  def down
    change_column :activities, :data, :text, collation: 'utf8_unicode_ci'
  end
end
