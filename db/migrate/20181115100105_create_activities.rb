class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.references :user,         null: false
      t.string     :target_uid
      t.string     :category
      t.string     :user_ip,      null: false
      t.string     :continent,    null: true
      t.string     :country,      null: true
      t.string     :country_code, null: true
      t.string     :city,         null: true
      t.string     :user_agent,   null: false
      t.string     :topic,        null: false
      t.string     :action,       null: false
      t.string     :result,       null: false
      t.text       :data,         null: true, collation: "utf8mb4_unicode_ci"
      t.json       :coordinates

      t.timestamp  :created_at # avoid updated_at as records not supposed to be updated
    end

    add_index :activities, :target_uid
    add_index  :activities, :country_code
  end
end
