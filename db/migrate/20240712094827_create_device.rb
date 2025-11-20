class CreateDevice < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.references :user,     null: true
      t.string :device_id,    null: false
      t.string :device_type,  null: false
      t.string :device_token
      t.boolean :active,      null: false, default: false

      t.timestamps
    end

    add_index :devices, %i[user_id device_id device_type], unique: true
  end
end
