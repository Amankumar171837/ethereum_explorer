class CreateAuthorizedClient < ActiveRecord::Migration[5.2]
  def change
    create_table :authorized_clients do |t|
      t.references :user
      t.references :registered_client
      t.datetime   :connected_at
      t.string     :status

      t.timestamps
    end

    add_index :authorized_clients, :status
  end
end
