# frozen_string_literal: true

# Ding sms sender
class DingService
  Error = Class.new(StandardError)

  include SmsHelper

  class << self
    def send_confirmation(phone, _channel, settings: nil)
      Rails.logger.info("Sending SMS to #{phone.number} with settings #{settings.inspect}")

      send_sms(number: phone.number, options: settings)
    rescue StandardError => e
      { error: e.message }
    end

    def send_verify_user(user, _channel, settings: nil)
      Rails.logger.info("Sending SMS to #{user.phone_number} with settings #{settings.inspect}")

      send_sms(number: user.phone_number, options: settings)
    rescue StandardError => e
      { error: e.message }
      Rails.logger.error { "Inspect error (Ding): #{e.inspect}\n#{e.backtrace.join("\n")}" }
    end

    # The code match will happen on the Ding Server Side
    def verify_user?(user:, code:)
      response = PlatformSetting.sms_service_client(user.phone_number).validate_code(
        {
          'target': {
            type: 'phone_number',
            value: "+#{user.phone_number}"
          },
          'code': code
        }
      )

      response['status'] == 'success'
    end
    # Creating alias because we need to override the default behavior of
    # verify_phone_user? method in the SMS Helper method
    alias_method :verify_phone_user?, :verify_user?

    def send_sms(number:, options: {})
      body = {
        'target': {
          type: 'phone_number',
          value: "+#{number}"
        },
        'signals': {
          'ip': options[:ip],
          'device_id': options[:device_id],
          'device_platform': options[:device_type]
        },
        options: {
          callback_url: Barong::App.config.ding_callback_url
        }
      }

      PlatformSetting.sms_service_client(number).send_code(body)
    end

    # The code match will happen on the Ding Server Side
    def verify_code?(number:, code:, user:)
      response = PlatformSetting.sms_service_client(number).validate_code(
        {
          'target': {
            type: 'phone_number',
            value: "+#{number}"
          },
          'code': code
        }
      )
      response['status'] == 'success'
    end
  end
end
