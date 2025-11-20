# frozen_string_literal: true

# twilio sms sender
class SmsalaService
  class << self
    include SmsHelper

    def send_confirmation(phone, _channel, settings: nil)
      Rails.logger.info("Sending SMS to #{phone.number}")

      sender = if settings
                 ::SmsSenderConfig.active.where(platform_setting: settings,
                                                country_code: Phonelib.parse(phone.number).country)
                                  .pluck(:sender).sample
               end

      send_sms(number: phone.number,
               content: Barong::App.config.sms_content_template.gsub(/{{code}}/, phone.code),
               options: { uid: phone.user.referral_code, sender: sender })
    rescue StandardError => e
      { error: e.message }
    end

    def send_verify_user(user, _channel, settings: nil)
      Rails.logger.info("Sending SMS to #{user.phone_number}")

      sender = if settings
                 ::SmsSenderConfig.active.where(platform_setting: settings,
                                                country_code: Phonelib.parse(user.phone_number).country)
                                  .pluck(:sender).sample
               end

      send_sms(number: user.phone_number,
               content: Barong::App.config.sms_content_template.gsub(/{{code}}/, user.phone_code),
               options: { uid: user.referral_code, sender: sender })
    rescue StandardError => e
      { error: e.message }
    end

    def verify_user?(user:, code:)
      user.code == code && user.code_expiry_date >= Time.now
    end

    # @param options : referral_code is used here to sent in the uid value
    # and sending sender_id as well.
    def send_sms(number:, content:, options: {})
      PlatformSetting.sms_service_client(number).send_code(
        {
          'phonenumber': number,
          'textmessage': content,
          'sms_type': 'T',
          'encoding': 'T',
          'uid': options[:uid],
          'sender_id': options[:sender]
        }
      )
    end

    # returns true if given code matches number in DB
    def verify_code?(number:, code:, user:)
      phone = user.phones.find_by_number(number, code: code)
      phone && phone.code_expiry_date >= Time.now
    end
  end
end
