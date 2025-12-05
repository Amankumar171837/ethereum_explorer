# frozen_string_literal: true

module API
  module V2
    module Entities
      # Basic user info with phone
      class UserWithPhone < API::V2::Entities::Base
        expose :filter_email,
               as: :email,
               documentation: {
                 type: 'String',
                 desc: 'User\'s Email'
               }

        expose :first_name,
               documentation: {
                 type: 'String',
                 desc: 'User\'s First Name'
               }

        expose :last_name,
               documentation: {
                 type: 'String',
                 desc: 'User\'s Last Name'
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

        expose :phone_number,
               documentation: {
                 type: 'String',
                 desc: 'User\'s phone number'
               }

        expose :csrf_token,
               documentation: {
                 type: 'String',
                 desc: 'Сsrf protection token'
               },
               if: ->(_, options) { options[:csrf_token] } do |_user, options|
          options[:csrf_token]
        end

        expose :uid,
               documentation: {
                 type: 'String',
                 desc: 'User\'s UID'
               }

        expose :role,
               documentation: {
                 type: 'String',
                 desc: 'User\'s role'
               }

        expose :institution,
               documentation: {
                 type: 'String',
                 desc: 'Institution\'s name'
               }

        expose :level,
               documentation: {
                 type: 'Integer',
                 desc: 'User\'s level'
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

        expose :otp,
               documentation: {
                 type: 'Boolean',
                 desc: 'is 2FA enabled for account'
               }

        expose :state,
               documentation: {
                 type: 'String',
                 desc: 'User\'s state: active, pending, inactive'
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

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
