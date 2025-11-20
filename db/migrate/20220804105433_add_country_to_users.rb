class AddCountryToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :country, :string, after: :metadata
  end
end
