class CreateUserSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_settings do |t|
      t.references :user
      t.datetime :username_updated, default: '1947-02-02 00:00:00'
      t.datetime :email_updated, default: '1947-02-02 00:00:00'
      t.datetime :phone_number_updated, default: '1947-02-02 00:00:00'
      t.text :metadata

      t.timestamps
    end
  end
end
