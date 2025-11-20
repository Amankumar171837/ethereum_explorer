class AddLastLoginIpAddressToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_ip, :string, null: false, default: '0.0.0.0', after: :metadata
    add_column :users, :last_country, :string, after: :last_ip
  end
end
