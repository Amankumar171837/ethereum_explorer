# frozen_string_literal: true

module API
  module V2
    module Entities
      # User information containing profile, labels and documents
      class UserWithFullInfo < API::V2::Entities::Base
        expose :filter_email,
               as: :email,
               documentation: {
                 type: 'String',
                 desc: 'User Email'
               }

        expose :first_name,
               documentation: {
                 type: 'String',
                 desc: 'User first name'
               }

        expose :last_name,
               documentation: {
                 type: 'String',
                 desc: 'User last name'
               }

        expose :full_name,
               documentation: {
                 type: 'String',
                 desc: 'User full name'
               }

        expose :username,
               documentation: {
                 type: 'String',
                 desc: 'User\'s username'
               }

        expose :uid,
               documentation: {
                 type: 'String',
                 desc: 'User UID'
               }

        expose :dob,
               documentation: {
                 desc: 'User date of birth.',
                 type: String
               }

        expose :role,
               documentation: {
                 type: 'String',
                 desc: 'User role'
               }

        expose :level,
               documentation: {
                 type: 'Integer',
                 desc: 'User level'
               }

        expose :otp,
               documentation: {
                 type: 'Boolean',
                 desc: 'is 2FA enabled for account'
               }

        expose :profile_url,
               documentation: {
                 type: 'Hash',
                 desc: 'Profile picture Url'
               }

        expose :profile_type,
               documentation: {
                 type: String,
                 desc: 'Profile picture type'
               }

        expose :state,
               documentation: {
                 type: 'String',
                 desc: 'User state: active, pending, inactive'
               }

        expose :country,
               documentation: {
                 desc: 'User country',
                 type: String
               }

        expose :last_country,
               documentation: {
                 desc: 'Last IP Geolocation.',
                 type: String
               }

        expose :last_ip,
               documentation: {
                 desc: 'Last IP Address.',
                 type: String
               }

        expose :phone_number,
               documentation: {
                 type: 'String',
                 desc: 'User Phone number'
               }

        expose :data,
               documentation: {
                 type: 'String',
                 desc: 'Additional phone and profile info'
               }

        expose :csrf_token,
               documentation: {
                 type: 'String',
                 desc: 'Сsrf protection token'
               },
               if: ->(_, options) {options[:csrf_token]} do |_user, options|
                 options[:csrf_token]
               end

        expose :authentication,
               documentation: {
                 type: 'String',
                 desc: 'Сsrf protection token'
               },
               if: ->(_, options) {options[:authentication]} do |_user, options|
                 options[:authentication]
               end

        expose :referral_code,
               documentation: {
                 desc: 'User unique referral code.',
                 type: String
               }

        expose :password_enabled,
               as: :login_via_password,
               documentation: {
                 desc: 'User can login via password or not.',
                 type: String
               }

        expose :labels, using: Entities::Label
        expose :phones, using: Entities::Phone

        expose(
          :without_social_profile,
          as: :profiles,
          using: Entities::Profile
        )

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
