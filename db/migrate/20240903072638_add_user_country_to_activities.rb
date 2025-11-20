class AddUserCountryToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :country, :string, after: :user_ip
    add_column :activities, :country_code, :string, after: :country
  end
end
