# frozen_string_literal: true

# twilio sms sender
class TwilioSmsSendService
  class << self
    include SmsHelper

    def send_confirmation(phone, _channel, settings: nil)
      Rails.logger.info("Sending SMS to #{phone.number}")

      send_sms(number: phone.number,
               content: Barong::App.config.sms_content_template.gsub(/{{code}}/, phone.code))
    rescue StandardError => e
      { error: e.message }
    end

    def send_verify_user(user, _channel, settings: nil)
      Rails.logger.info("Sending SMS to #{user.phone_number}")

      send_sms(number: user.phone_number,
               content: Barong::App.config.sms_content_template.gsub(/{{code}}/, user.phone_code))
    rescue StandardError => e
      { error: e.message }
    end

    def verify_user?(user:, code:)
      user.code == code && user.code_expiry_date >= Time.now
    end

    def send_sms(number:, content:)
      from_phone = Barong::App.config.twilio_phone_number
      PlatformSetting.sms_service_client(number).messages.create(
        from: from_phone,
        to:   '+' + number,
        body: content
      )
    end

    # returns true if given code matches number in DB
    def verify_code?(number:, code:, user:)
      phone = user.phones.find_by_number(number, code: code)
      phone && phone.code_expiry_date >= Time.now
    end
  end
end
