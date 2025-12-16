class CreateClientWebhook < ActiveRecord::Migration[5.2]
  def change
    create_table :client_webhooks do |t|
      t.references :registered_client
      t.string :url,    null: false
      t.string :event,  null: false
      t.string :status, null: false, default: 'active'

      t.timestamps
    end

    add_index :client_webhooks, %i[event registered_client_id], unique: true
  end
end
