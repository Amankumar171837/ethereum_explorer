class AddUsaDisclaimerToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :usa_disclaimer, :boolean, after: :last_country, null: false, default: false
  end
end
