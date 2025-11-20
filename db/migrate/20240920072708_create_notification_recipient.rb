class CreateNotificationRecipient < ActiveRecord::Migration[5.2]
  def change
    create_table :notification_recipients do |t|
      t.references :notification
      t.references :user
      t.references :device
      t.string     :status
      t.json       :metadata

      t.timestamps
    end
  end
end
