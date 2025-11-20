class CreateSmsSenderConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :sms_sender_configs do |t|
      t.references :platform_setting
      t.string  :country
      t.string  :country_code
      t.string  :sender
      t.integer :status
      t.text    :metadata

      t.timestamps
    end
  end
end
