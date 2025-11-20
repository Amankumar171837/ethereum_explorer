# frozen_string_literal: true

module API::V2
  module Admin
    module Entities
      class PlatformSettings < API::V2::Entities::Base
        expose :id,
               documentation: {
                 type: Integer,
                 desc: 'Platform settings id'
               }

        expose :service_type,
               documentation: {
                 type: String,
                 desc: 'SMS service using in the platform.'
               }

        expose :service_name,
               documentation: {
                 type: String,
                 desc: 'Email service using in the platform.'
               }

        expose :service_key,
               documentation: {
                 type: String,
                 desc: 'SMS service using in the platform.'
               }

        expose :metadata,
               documentation: {
                 type: String,
                 desc: 'Other Related data or creds'
               }

        expose :state,
               documentation: {
                 type: String,
                 desc: 'Setting state is enabled/disabled'
               }

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
