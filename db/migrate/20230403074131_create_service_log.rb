class CreateServiceLog < ActiveRecord::Migration[5.2]
  def change
    create_table :service_logs do |t|
      t.string :service_name,              null: false
      t.string :service_type,              null: false
      t.references :user,             null: false
      t.references :platform_setting, null: false
      t.string :topic,                     null: false
      t.string :result,                    null: false
      t.string :user_ip,                   null: false
      t.string :user_country
      t.json :metadata

      t.timestamps
    end
  end
end
