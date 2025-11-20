# frozen_string_literal: true

# twilio process verification
class TwilioVerifyService
  class << self
    include SmsHelper

    def send_confirmation(phone, channel, settings: nil)
      Rails.logger.info("Sending code to #{phone.number} via #{channel}")

      send_code(number: phone.number, channel: channel)
    rescue StandardError => e
      { error: e.message }
    end

    def send_code(number:, channel:)
      verify_client.services(@service_sid)
                   .verifications
                   .create(to: '+' + number, channel: channel)
    end

    # return true if twilio accepts given code for the given number
    def verify_code?(number:, code:, user:)
      verify_client = verify_client(number)
      status = verify_client.services(@service_sid)
                            .verification_checks
                            .create(to: '+' + number, code: code)
                            .status

      status == 'approved'
    end

    def verify_client(number)
      client = PlatformSetting.sms_service_client(number)
      @service_sid = client.verify.services.create(friendly_name: Barong::App.config.app_name)

      client.verify
    end
  end
end
