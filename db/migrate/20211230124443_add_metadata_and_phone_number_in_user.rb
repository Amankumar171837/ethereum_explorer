class AddMetadataAndPhoneNumberInUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :metadata, :json, after: :referral_id
    add_column :users, :phone_number, :string, after: :email
    add_column :users, :first_name, :string, after: :phone_number
    add_column :users, :last_name, :string, after: :first_name
    add_column :users, :username, :string, after: :last_name
  end
end
