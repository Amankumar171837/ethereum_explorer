class AddCityAndContinentToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :continent, :string, after: :user_ip, index: true
    add_column :activities, :city, :string, after: :country_code, index: true
    add_column :activities, :coordinates, :json, after: :city
    add_index  :activities, :country_code
  end
end
