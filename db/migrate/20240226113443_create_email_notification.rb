class CreateEmailNotification < ActiveRecord::Migration[5.2]
  def change
    create_table :email_notifications do |t|
      t.references :user,       null: false
      t.references :email_type, null: false
      t.string :email,          null: false
      t.boolean :enabled,       default: true

      t.timestamps
    end
    add_index :email_notifications, %i[user_id email email_type_id], name: 'index_email_notification_user_email_type', unique: true
  end
end
