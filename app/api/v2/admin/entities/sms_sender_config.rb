# frozen_string_literal: true

module API::V2
  module Admin
    module Entities
      class SmsSenderConfig < API::V2::Entities::Base
        expose :id,
               documentation: {
                 type: Integer,
                 desc: 'SMS Sender config id'
               }

        expose :country,
               as: :country_name,
               documentation: {
                 type: String,
                 desc: 'SMS Sender config country name.'
               }

        expose :country_code,
               documentation: {
                 type: String,
                 desc: 'SMS Sender config country code.'
               }

        expose :sender,
               documentation: {
                 type: String,
                 desc: 'SMS Sender config sender name.'
               }

        expose :status,
               documentation: {
                 type: String,
                 desc: 'SMS Sender config status is active/inactive'
               }

        expose :metadata,
               documentation: {
                 type: String,
                 desc: 'SMS Sender config metadata'
               }

        expose :platform_setting, using: Entities::PlatformSettings

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
