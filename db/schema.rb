# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_11_27_150128) do

  create_table "activities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "target_uid"
    t.string "category"
    t.string "user_ip", null: false
    t.string "continent"
    t.string "country"
    t.string "country_code"
    t.string "city"
    t.string "user_agent", null: false
    t.string "topic", null: false
    t.string "action", null: false
    t.string "result", null: false
    t.text "data", collation: "utf8mb4_unicode_ci"
    t.json "coordinates"
    t.timestamp "created_at"
    t.index ["country_code"], name: "index_activities_on_country_code"
    t.index ["target_uid"], name: "index_activities_on_target_uid"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "apikeys", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "key_holder_account_id", null: false, unsigned: true
    t.string "key_holder_account_type", default: "User", null: false
    t.string "kid", null: false
    t.string "algorithm", null: false
    t.string "scope"
    t.string "secret_encrypted", limit: 1024
    t.string "state", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key_holder_account_type", "key_holder_account_id"], name: "idx_apikey_on_account"
    t.index ["kid"], name: "index_apikeys_on_kid", unique: true
  end

  create_table "country_services", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "continent"
    t.string "country_name", null: false
    t.string "country_code", null: false
    t.string "state", default: "enabled", null: false
    t.string "service_type", null: false
    t.bigint "platform_setting_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["platform_setting_id"], name: "index_country_services_on_platform_setting_id"
  end

  create_table "devices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "device_id", null: false
    t.string "device_type", null: false
    t.string "device_token"
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "device_id", "device_type"], name: "index_devices_on_user_id_and_device_id_and_device_type", unique: true
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "email_notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "email_type_id", null: false
    t.string "email", null: false
    t.boolean "enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_type_id"], name: "index_email_notifications_on_email_type_id"
    t.index ["user_id", "email", "email_type_id"], name: "index_email_notification_user_email_type", unique: true
    t.index ["user_id"], name: "index_email_notifications_on_user_id"
  end

  create_table "email_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_email_types_on_name", unique: true
  end

  create_table "labels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false, unsigned: true
    t.string "key", null: false
    t.string "value", null: false
    t.string "scope", default: "public", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "key", "scope"], name: "index_labels_on_user_id_and_key_and_scope"
    t.index ["user_id"], name: "index_labels_on_user_id"
  end

  create_table "levels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "media", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false, unsigned: true
    t.string "upload"
    t.string "moderation_score"
    t.text "moderation_metadata"
    t.json "image_urls"
    t.string "type"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notification_recipients", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "notification_id"
    t.bigint "user_id"
    t.bigint "device_id"
    t.string "status"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_notification_recipients_on_device_id"
    t.index ["notification_id"], name: "index_notification_recipients_on_notification_id"
    t.index ["user_id"], name: "index_notification_recipients_on_user_id"
  end

  create_table "notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "action", null: false
    t.string "role", null: false
    t.string "verb", null: false
    t.string "path", null: false
    t.string "topic"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic"], name: "index_permissions_on_topic"
  end

  create_table "phones", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id", null: false, unsigned: true
    t.string "country", null: false
    t.string "code", limit: 5
    t.string "number_encrypted", null: false
    t.bigint "number_index", null: false
    t.datetime "validated_at"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number_index"], name: "index_phones_on_number_index"
    t.index ["user_id"], name: "index_phones_on_user_id"
  end

  create_table "platform_settings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "service_key", null: false
    t.string "service_name", null: false
    t.string "service_type", null: false
    t.string "state", default: "enabled", null: false
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "author"
    t.string "first_name_encrypted", limit: 1024
    t.string "last_name_encrypted", limit: 1024
    t.string "middle_name_encrypted", limit: 1024
    t.string "dob_encrypted"
    t.string "address_encrypted", limit: 1024
    t.string "postcode"
    t.string "city"
    t.string "country"
    t.integer "state", limit: 1, default: 0, unsigned: true
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "registered_clients", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "kid", null: false
    t.string "secret_encrypted", limit: 1024
    t.string "scope"
    t.string "redirect_url", null: false
    t.string "state", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kid"], name: "index_registered_clients_on_kid", unique: true
  end

  create_table "restrictions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "category", null: false
    t.string "scope", limit: 64, null: false
    t.string "value", limit: 64, null: false
    t.integer "code"
    t.string "state", limit: 16, default: "enabled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "uid", null: false
    t.bigint "owner_id", null: false, unsigned: true
    t.string "email", null: false
    t.string "role", default: "service_account", null: false
    t.integer "level", default: 0, null: false
    t.string "state", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "service_name", null: false
    t.string "service_type", null: false
    t.bigint "user_id", null: false
    t.bigint "platform_setting_id", null: false
    t.string "topic", null: false
    t.string "result", null: false
    t.string "user_ip", null: false
    t.string "user_country"
    t.string "phone_number"
    t.string "sms_id"
    t.string "country_code"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_number"], name: "index_service_logs_on_phone_number"
    t.index ["platform_setting_id"], name: "index_service_logs_on_platform_setting_id"
    t.index ["user_id"], name: "index_service_logs_on_user_id"
  end

  create_table "sms_sender_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "platform_setting_id"
    t.string "country"
    t.string "country_code"
    t.string "sender"
    t.integer "status"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["platform_setting_id"], name: "index_sms_sender_configs_on_platform_setting_id"
  end

  create_table "user_state_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false, unsigned: true
    t.bigint "admin_id", null: false
    t.string "past_state", null: false
    t.string "state", null: false
    t.string "remark", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_state_logs_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "uid", null: false
    t.string "email", null: false
    t.string "phone_number"
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.string "password_digest", null: false
    t.boolean "password_enabled", default: true
    t.string "role", default: "member", null: false
    t.string "platform"
    t.text "data"
    t.integer "level", default: 0, null: false
    t.boolean "otp", default: false
    t.string "state", default: "pending", null: false
    t.bigint "referral_id"
    t.string "referral_code"
    t.integer "users_count", default: 0, null: false
    t.json "metadata"
    t.string "country"
    t.string "last_ip", default: "0.0.0.0", null: false
    t.string "last_country"
    t.datetime "password_reset_at", default: "1947-02-02 00:00:00"
    t.string "social_media_status", default: "active"
    t.datetime "status_updated_at", default: "1947-02-02 00:00:00"
    t.json "login_metadata"
    t.text "general_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number"
    t.index ["platform"], name: "index_users_on_platform"
    t.index ["referral_code"], name: "index_users_on_referral_code", unique: true
    t.index ["state"], name: "index_users_on_state"
    t.index ["uid"], name: "index_users_on_uid", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
