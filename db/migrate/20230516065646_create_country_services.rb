class CreateCountryServices < ActiveRecord::Migration[5.2]
  def change
    create_table :country_services do |t|
      t.string :continent
      t.string :country_name,              null: false
      t.string :country_code,              null: false
      t.string :state,                     default: 'enabled', null: false
      t.string :service_type,              null: false
      t.references :platform_setting, null: false
      t.timestamps
    end
  end
end
