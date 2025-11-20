class CreatePlatformSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :platform_settings do |t|
      t.string :service_key, null: false
      t.string :service_name, null: false
      t.string :service_type, null: false
      t.string :state, :string, default: 'enabled', null: false
      t.json   :metadata

      t.timestamps
    end
  end
end
