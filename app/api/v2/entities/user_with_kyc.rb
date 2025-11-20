# frozen_string_literal: true

module API
  module V2
    module Entities
      # User information containing profile, labels and documents
      class UserWithKYC < API::V2::Entities::Base
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
                 desc: 'User state: active, pending, inactive'
               }

        expose :country,
               documentation: {
                 desc: 'User country',
                 type: String
               }

        expose :country_of_residence,
               documentation: {
                 desc: 'country of residence',
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

        expose :agreement,
               documentation: {
                 desc: 'User USA Disclaimer.',
                 type: String
               }

        expose :phone_number,
               documentation: {
                 type: 'String',
                 desc: 'User Phone number'
               }

        # TODO :: Remove me if not needed in future
        # expose :referral_uid,
        #        documentation: {
        #         type: 'String',
        #         desc: 'UID of referrer'
        #        } do |user|
        #           user.referral_uid
        #        end

        expose :data,
               documentation: {
                 type: 'String',
                 desc: 'Additional phone and profile info'
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

        expose :users_count,
               as: :referrals,
               documentation: {
                 type: String,
                 desc: 'Referred user\'s referral count'
               }

        expose(
          :without_social_profile,
          as: :profiles,
          using: Entities::Profile
        )
        expose :labels, using: Entities::AdminLabelView
        expose :phones, using: Entities::Phone
        expose :data_storages, using: Entities::DataStorage
        expose :comments, using: Entities::Comment

        # activities, as sensitive and potentialy too big data should be queried separately

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
          expose :agreement_time
        end
      end
    end
  end
end
