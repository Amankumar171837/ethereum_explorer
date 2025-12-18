# frozen_string_literal: true

module API::V2
  module Entities
    class UserWithProfile < API::V2::Entities::Base
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

      expose :kyc_status,
             documentation: {
               desc: 'User kyc status',
               type: String
             }

      expose :applicant_id,
             documentation: {
                 desc: 'Kyc applicant id.',
                 type: String
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

      expose :platform,
             documentation: {
               type: String,
               desc: 'Platform from which user signed up.'
             }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
        expose :updated_at
      end
    end
  end
end
