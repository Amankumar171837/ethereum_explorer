# frozen_string_literal: true


# 1/ check if ENV key exist then validate and set
# 2/ if no check in credentials then validate and set
# 3/ if no generate display warning, raise error in production, and set

require 'barong/app'
require 'barong/keystore'

private_key_path = ENV['JWT_PRIVATE_KEY_PATH']

if !private_key_path.nil?
  pkey = Barong::KeyStore.open!(private_key_path)
  Rails.logger.error('Loading private key from: ' + private_key_path)

elsif Rails.application.credentials.has?(:private_key)
  pkey = Barong::KeyStore.read!(Rails.application.credentials.private_key)
  Rails.logger.info('Loading private key from credentials.yml.enc')

elsif !Rails.env.production?
  # Generates private key
  key = Barong::KeyStore.generate
  pkey = key.to_pem
  pub_key = key.public_key.to_pem

  # Save private/public keys
  Barong::KeyStore.save!(pkey, 'config/rsa-key')
  Barong::KeyStore.save!(pub_key, 'config/rsa-key.pub')

  Rails.logger.warn('Warning !! Generating private key')
else
  raise 'Private key not found or invalid'
end

kstore = Barong::KeyStore.new(pkey)

# Define default value for secret_key_base in test and development mode
ENV['SECRET_KEY_BASE'] = '' unless Rails.env.production?

Barong::App.define do |config|
  # General configuration ---------------------------------------------
  # https://www.openware.com/sdk/docs/barong/configuration.html#general-configuration
  config.set(:app_name, 'Barong')
  config.set(:domain, 'openware.com')
  config.set(:otp_domain, 'blockmaze.com')
  config.set(:uid_prefix, 'ID', regex: /^[A-z]{2,6}$/)
  config.set(:session_name, '_barong_session')
  config.set(:session_expire_time, '1800', type: :integer)
  config.set(:required_docs_expire, 'false', type: :bool)
  config.set(:doc_num_limit, '10', type: :integer)
  config.set(:geoip_lang, 'en', values: %w[en de es fr ja ru])
  config.set(:csrf_protection, 'true', type: :bool)
  config.set(:apikey_nonce_lifetime, '5000', type: :integer)
  config.set(:gateway, 'cloudflare', values: %w[akamai cloudflare])
  config.set(:jwt_expire_time, '3600', type: :integer)
  config.set(:profile_double_verification, 'false', type: :bool)
  config.set(:crc32_salt, '')
  config.set(:api_data_masking_enabled, 'true', type: :bool)
  config.set(:account_delete_period, '30', type: :integer)

  # Password configuration  -----------------------------------------------
  # https://www.openware.com/sdk/docs/barong/configuration.html#password-configuration
  config.set(:password_regexp, '^(?=.*[[:lower:]])(?=.*[[:upper:]])(?=.*[[:digit:]])(?=.*[[:graph:]]).{8,80}$', type: :regexp)
  config.set(:password_min_entropy, '14', type: :integer)
  config.set(:password_use_dictionary, 'true', type: :bool)

  # CAPTCHA configuration ---------------------------------------------
  # https://www.openware.com/sdk/docs/barong/configuration.html#captcha-configuration
  config.set(:captcha, 'none', values: %w[none recaptcha geetest turnstile])
  config.set(:geetest_id, '')
  config.set(:geetest_key, '')
  config.set(:recaptcha_site_key, '')
  config.set(:recaptcha_secret_key, '')
  config.set(:turnstile_site_key, '')
  config.set(:turnstile_secret_key, '')
  config.set(:recaptcha_bypass, 'f63mgqyTdHSKD3PZ4IbewujX33w2nHIJRQ61t3aQYj15yF6XI')

  # Dependencies configuration (vault, redis, rabbitmq) ---------------
  # https://www.openware.com/sdk/docs/barong/configuration.html#dependencies-configuration-vault-redis-rabbitmq
  config.set(:event_api_rabbitmq_host, 'localhost')
  config.set(:event_api_rabbitmq_port, '5672')
  config.set(:event_api_rabbitmq_username, 'guest')
  config.set(:event_api_rabbitmq_password, 'guest')
  config.set(:vault_address, 'http://localhost:8200')
  config.set(:vault_token, '')
  config.set(:redis_cluster, 'false', type: :bool)
  config.set(:redis_url, 'redis://localhost:6379/1')
  config.set(:redis_password, '')
  config.set(:vault_app_name, 'barong')

  # CORS configuration  -----------------------------------------------
  # https://www.openware.com/sdk/docs/barong/configuration.html#api-cors-configuration
  config.set(:api_cors_origins, '*')
  config.set(:api_cors_max_age, '3600')
  config.set(:api_cors_allow_credentials, 'false', type: :bool)

  # Config files configuration ----------------------------------------
  # https://www.openware.com/sdk/docs/barong/configuration.html#config-files-configuration
  config.set(:config, 'config/barong.yml', type: :path)
  config.set(:maxminddb_path, '', type: :path)
  config.set(:maxminddb_city_path, '', type: :path)
  config.set(:seeds_file, Rails.root.join('config', 'seeds.yml'), type: :path)
  config.set(:authz_rules_file, Rails.root.join('config', 'authz_rules.yml'), type: :path)
  config.set(:user_agents, Rails.root.join('config', 'custom_user_agent.yml'), type: :path)
  config.set(:sign_auth, Rails.root.join('config', 'sign_auth.yml'), type: :path)

  # SMTP configuration ----------------------------------------------
  # https://github.com/openware/barong/blob/master/docs/general/env_configuration.md#smtp-configuration
  config.set(:sender_email, 'noreply@barong.io')
  config.set(:sender_name, 'Barong')
  config.set(:smtp_password, '')
  config.set(:smtp_port, 1025)
  config.set(:smtp_host, 'localhost')
  config.set(:smtp_user, '')
  config.set(:smtp_logo_link, 'https://storage.cloud.google.com/public_peatio/logo.png')
  config.set(:default_language, 'en')

  # Auth0 configuration ---------------------------------------------
  config.set(:auth0_domain, '')
  config.set(:auth0_client_id, '')

  # JWT session configuration ---------------------------------------
  config.set(:jwt_session_expire_time, 3600)
  config.set(:jwt_refresh_expire_time, 7200)
  config.set(:jwt_refresh_update_time, 7200)
  config.set(:device_jwt_refresh_exp_time, '604800', type: :integer)
  config.set(:opaque_jwt_access_length, '64', type: :integer)

  # Email configurations --------------------------------------------
  config.set(:disable_fake_mail, false)
  config.set(:sanitize_email_enabled, true)
  config.set(:enable_sendgrid_email_checker, false)
  config.set(:from_name, 'Blockmaze')
  config.set(:sendgrid_email_api_key, '')
  config.set(:sendgrid_verdict, %w[valid riskey])
  config.set(:sendgrid_score_enabled, true)
  # 0.5 = 50% ; 0.01 = 1% ;
  config.set(:sendgrid_score, 0.5)

  # Activity count configurations -----------------------------------
  config.set(:activity_count_multiplier, 1)

  # Image Size configurations ---------------------------------------
  config.set(:image_versions_path, 'config/image_versions.yml', type: :path)
  config.set(:image_versions, YAML.load_file(Barong::App.config.image_versions_path))
  # Setting here because of the image_versions.yml file dependency.
  config.write(:avatar_uploader, AvatarUploader)

  config.set(:referrals_count, 7)
  config.set(:l3, 15)
  config.set(:l4, 7)
  config.set(:public_referrals_min_profile, 10)
  config.set(:public_referrals_max_profile, 20)

  # Redpanda configurations -----------------------------------------
  config.set(:redpanda_hosts, '')
  config.set(:redpanda_logs_level, '')
  config.set(:redpanda_partition_eof, 'msg')
  config.set(:redpanda_sasl_username, '')
  config.set(:redpanda_sasl_password, '')
  config.set(:redpanda_sasl_mechanism, 'SCRAM-SHA-512')
  config.set(:redpanda_sasl_protocol, 'sasl_plaintext')
  config.set(:redpanda_jwt_private_key, '')
  config.set(:redpanda_jwt_algorithm, '')
  config.set(:redpanda_topic_prefix, '')
  config.set(:redpanda_group_id, '')

  # Update limit configurations -------------------------------------
  config.set(:update_phone_number_max, 1)
  config.set(:update_phone_number_max_days, 30)
  config.set(:update_email_max, 1)
  config.set(:update_email_max_days, 15)
  config.set(:update_username, 1)
  config.set(:update_username_max_days, 15)

  # OTP Configurations ----------------------------------------------
  # After 2 attempt the system will block the user to resend again till
  # resend_otp_limit_reached minutes
  config.set(:resend_otp_max, 2)
  # value should be minutes only
  config.set(:resend_otp_limit_reached, 60)

  # Signature validation --------------------------------------------
  config.set(:app_auth_token, '')
  # Set in seconds
  config.set(:app_auth_token_lifetime, '3000', type: :integer)
  config.set(:app_auth_nonce_lifetime, '600000', type: :integer)
  # Ding Configurations ---------------------------------------------
  config.set(:ding_api_endpoint, 'https://api.ding.live/')
  config.set(:ding_customer_uuid, '')
  config.set(:ding_api_key, '')
  config.set(:ding_callback_url, '')

  # Elasticsearch configurations ------------------------------------
  config.set(:batch_size, '10000', type: :integer)
  config.set(:scroll_time, '1m')

  # User requirement configurations ---------------------------------
  config.set(:minimum_age_to_register, '12', type: :integer) #in years

  # AWS Pinpoint service configurations ----------------------------
  config.set(:aws_pinpoint_access_key, '')
  config.set(:aws_pinpoint_secret_key, '')
  config.set(:aws_pinpoint_storage_region, '')
  config.set(:aws_pinpoint_validation, 'false', type: :bool)
  config.set(:aws_pinpoint_allowed_phone_type, 'MOBILE, PREPAID',type: :array)

  # FCM Notification service configurations ----------------------------
  config.set(:fcm_project_id, '')
  config.set(:fcm_path, 'config/fcm_credential.json')
  config.set(:notification_batch_size, '100', type: :integer)

  config.set(:app_versions, Rails.root.join('config', 'app_versions.yml'), type: :path)
  config.set(:restricted_countries, '', type: :array)

  config.set(:users_valid_from, '1749753000', type: :integer)

  config.set(:auth_code_expiry, '600', type: :integer)
  config.set(:client_id_prefix, 'cid_')
  config.set(:kyc_level, '2', type: :integer)
  config.set(:webhook_retry_count, '20', type: :integer)
end

ActionMailer::Base.smtp_settings = {
  address: Barong::App.config.smtp_host,
  port: Barong::App.config.smtp_port,
  user_name: Barong::App.config.smtp_user,
  password: Barong::App.config.smtp_password
}

Barong::GeoIP.lang = Barong::App.config.geoip_lang

Rails.application.config.x.keystore = kstore
Barong::App.config.keystore = kstore
