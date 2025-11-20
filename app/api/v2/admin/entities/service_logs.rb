# frozen_string_literal: true

module API::V2::Admin
  module Entities
    class ServiceLogs < API::V2::Entities::Base
      expose(
        :email,
        documentation: {
          desc: 'User Email.',
          type: String
        }
      ) { |s| s.user&.email }

      expose(
        :uid,
        documentation: {
          desc: 'User UID.',
          type: String
        }
      ) { |s| s.user&.uid }


      expose :service_name,
             documentation: {
               type: String,
               desc: 'Service name used by user.'
             }

      expose :service_type,
             documentation: {
               type: String,
               desc: 'Service type used by user'
             }

      expose :topic,
             documentation: {
               type: String,
               desc: 'Defined topic or general by default'
             }

      expose :result,
             documentation: {
               type: String,
               desc: 'Status of API response: succeed, failed, denied'
             }

      expose :phone_number,
             documentation: {
               type: String,
               desc: 'user phone number'
             }

      expose :metadata,
             documentation: {
               type: JSON,
               desc: 'Parameters which was sent to specific API endpoint'
             }

      expose :user_ip,
             documentation: {
               type: String,
               desc: 'User IP.'
             }

      expose :user_country,
             documentation: {
               type: String,
               desc: 'User country'
             }

      expose :country_code,
             documentation: {
               type: String,
               desc: 'User country code'
             }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
      end
    end
  end
end
