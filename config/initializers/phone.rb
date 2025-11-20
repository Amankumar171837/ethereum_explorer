# frozen_string_literal: true

require_dependency 'barong/mock_sms'

Barong::App.define do |config|
  # Twilio configuration ----------------------
  # https://www.openware.com/sdk/docs/barong/configuration.html#twilio-configuration

  config.write(:twilio_provider, TwilioSmsSendService)

  config.set(:phone_verification, 'mock')
  config.set(:twilio_phone_number, '+15005550000')
  config.set(:twilio_account_sid, '')
  config.set(:twilio_auth_token, '')
  config.set(:twilio_service_sid, '')
  config.set(:sms_content_template, 'Your verification code for Barong: {{code}}')
  config.set(:user_phones_limit, 3)
  config.set(:bulkgate_application_id, '')
  config.set(:bulkgate_application_token, '')
  config.set(:sms_aws_region, '')
  config.set(:sms_aws_access_key_id ,'')
  config.set(:sms_aws_secret_access_key, '')
  # SMSala configurations -----------------------
  config.set(:smsala_api_id, '')
  config.set(:smsala_api_password, '')
  config.set(:smsala_callback_url, '')
  # Mobivate configurations -----------------------
  config.set(:mobivate_api_key, '')
  config.set(:mobivate_route, 'mglobal')
end

Phonelib.strict_check = true
Phonelib.strict_double_prefix_check = true
