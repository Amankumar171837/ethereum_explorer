class AddStateAndMetadataInPlatformSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :platform_settings, :state, :string, default: 'enabled', after: :service_name, null: false
    add_column :platform_settings, :metadata, :json, after: :service_key
  end
end
