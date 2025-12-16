# frozen_string_literal: true

module API
  module V2
    module Entities
      class UserWithOauth < API::V2::Entities::Base
        expose :uid,
               documentation: {
                 type: 'String',
                 desc: 'User UID'
               }

        expose :filter_email,
               as: :email,
               documentation: {
                 type: 'String',
                 desc: 'User Email'
               }

        expose :phone_number,
               documentation: {
                 type: 'String',
                 desc: 'User Phone number'
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

        expose :role,
               documentation: {
                 type: 'String',
                 desc: 'User role'
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
      end
    end
  end
end
