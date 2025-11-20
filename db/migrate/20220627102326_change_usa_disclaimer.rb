class ChangeUsaDisclaimer < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :usa_disclaimer, :agreement
    add_column :users, :agreement_time, :datetime, after: :agreement
  end
end
