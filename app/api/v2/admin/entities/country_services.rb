# frozen_string_literal: true

module API::V2
  module Admin
    module Entities
      class CountryServices < API::V2::Entities::Base
        expose :id,
               documentation: {
                 type: Integer,
                 desc: 'Country Service id'
               }

        expose :continent,
               documentation: {
                 type: String,
                 desc: 'Continent of Service'
               }

        expose :country_name,
               documentation: {
                 type: String,
                 desc: 'Country Name of Service'
               }

        expose :state,
               documentation: {
                 type: String,
                 desc: 'Service state is enabled/disabled'
               }

        expose :country_code,
               documentation: {
                 type: String,
                 desc: 'Country Code of Service'
               }

        expose :service_type,
               documentation: {
                 type: String,
                 desc: 'SMS service using in the Country.'
               }

        expose :platform_setting, using: API::V2::Admin::Entities::PlatformSettings

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
