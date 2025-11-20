class AddCountryCodeToServiceLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :service_logs, :country_code, :string, after: :user_country
  end
end
