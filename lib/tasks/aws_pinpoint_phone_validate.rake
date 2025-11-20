# frozen_string_literal: true

namespace :aws_pinpoint_phone_validate do

  desc "Disable user's with VOIP phone numbers only allow Mobile and Prepaid phone numbers"
  task :disable => :environment do |_|
    Rails.logger.info { "Started rake task for disabling users with fake number." }
    User.all.each do |user|
      if user.phone_number == '' || user.phone_number == nil
        Rails.logger.warn {"Skipping user (#{user.uid}) because it has empty phone number"}
        next

      end

      if user.state == 'pending'
        Rails.logger.warn {"Skipping user (#{user.uid}) because it's in pending state"}
        next

      end
      Barong::AwsPinpoint::PhoneValidate.validate(user.phone_number)

    rescue Barong::AwsPinpoint::PhoneValidate::InvalidPhoneNumberError => e
      Rails.logger.warn { "Blocking user (#{user.uid}) because it's phone number was not valid." }
      Rails.logger.warn { "Blocking user (#{user.uid}) because: #{e.message}" }

      user.update!(state: 'banned')
      Rails.logger.warn { "Blocking completed for user (#{user.uid})." }
    end
  end
end
