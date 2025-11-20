class AddVerificationInUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :password_enabled, :boolean, default: true, after: :password_digest
  end
end
