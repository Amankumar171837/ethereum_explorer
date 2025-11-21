class CreateAllTables < ActiveRecord::Migration[5.2]
  def change

    create_table :users do |t|
      t.string    :uid,                 null: false
      t.string    :email,               null: false
      t.string    :phone_number
      t.string    :first_name
      t.string    :last_name
      t.string    :username
      t.string    :password_digest,     null: false
      t.boolean   :password_enabled,    default: true
      t.string    :role,                default: "member", null: false
      t.string    :platform
      t.text      :data,                null: true
      t.integer   :level,               default: 0, null: false
      t.boolean   :otp,                 default: false
      t.string    :state,               default: "pending", null: false
      t.bigint    :referral_id,         null: true
      t.string    :referral_code,       limit: 255
      t.integer   :users_count,         null: false, default: 0
      t.json      :metadata
      t.string    :country
      t.string    :last_ip,             null: false, default: '0.0.0.0'
      t.string    :last_country
      t.datetime  :password_reset_at,   default: '1947-02-02 00:00:00'
      t.string    :social_media_status, default: 'active'
      t.datetime  :status_updated_at,   default: '1947-02-02 00:00:00'
      t.json      :login_metadata
      t.text      :general_info

      t.timestamps
    end
    add_index :users, :uid, unique: true
    add_index :users, :email, unique: true
    add_index :users, :referral_code, unique: true
    add_index :users, :username, unique: true
    add_index :users, :phone_number
    add_index :users, :platform
    add_index :users, :state

    create_table :apikeys do |t|
      t.bigint    :user_id,   null: false, unsigned: true
      t.string    :kid,       null: false
      t.string    :algorithm, null: false
      t.string    :scope
      t.string    :secret_encrypted, limit: 1024
      t.string    :state, default: "active", null: false
      t.timestamps
      t.index [:user_id]
    end

    create_table :labels do |t|
      t.bigint  :user_id, null: false, unsigned: true
      t.string  :key,     null: false
      t.string  :value,   null: false
      t.string  :scope,   default: "public", null: false
      t.string  :description, null: true
      t.timestamps
      t.index [:user_id]
      t.index [:user_id, :key, :scope]
    end

    create_table :levels do |t|
      t.string  :key, null: false
      t.string  :value
      t.string  :description
      t.timestamps
    end

    create_table :phones do |t|
      t.integer   :user_id, null: false, unsigned: true
      t.string    :country, null: false
      t.string    :code,    limit: 5
      t.string    :number_encrypted, null: false
      t.bigint    :number_index, null: false
      t.datetime  :validated_at
      t.json      :metadata
      t.timestamps
      t.index [:user_id]
    end
    add_index :phones, [:number_index]

    create_table :profiles do |t|
      t.bigint    :user_id
      t.string    :author, null: true
      t.string    :first_name_encrypted, limit: 1024
      t.string    :last_name_encrypted,  limit: 1024
      t.string    :middle_name_encrypted,  limit: 1024
      t.string    :dob_encrypted
      t.string    :address_encrypted, limit: 1024
      t.string    :postcode
      t.string    :city
      t.string    :country
      t.integer   :state, unsigned: true, limit: 1, default: 'drafted'
      t.text      :metadata
      t.timestamps
      t.index [:user_id]
    end
  end
end
