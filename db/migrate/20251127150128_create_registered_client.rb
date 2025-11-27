class CreateRegisteredClient < ActiveRecord::Migration[5.2]
  def change
    create_table :registered_clients do |t|
      t.string :name,             null: false
      t.string :kid,              null: false
      t.string :secret_encrypted, limit: 1024
      t.string :scope
      t.string :redirect_url,     null: false
      t.string :state,            null: false, default: 'active'

      t.timestamps
    end

    add_index :registered_clients, :kid, unique: true
  end
end
