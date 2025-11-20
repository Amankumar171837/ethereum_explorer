# frozen_string_literal: true

module SmsHelper
  def verify_phone_user?(user:, code:)
    user.phone_code == code && user.phone_code_expiry_date >= Time.now
  end

  def verify_email_user?(user:, code:)
    user.code == code && user.code_expiry_date >= Time.now
  end
end
