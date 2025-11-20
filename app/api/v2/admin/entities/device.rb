# frozen_string_literal: true

module API::V2
  module Admin
    module Entities
      class Device < API::V2::Entities::Base
        expose(
          :id,
          documentation: {
            type: Integer,
            desc: 'Device unique identifier'
          }
        )

        expose(
          :uid,
          documentation: {
            desc: 'user\'s uid',
            type: String
          }
        ) { |device| device&.user&.uid }

        expose(
          :email,
          documentation: {
            desc: 'user\'s email',
            type: String
          }
        ) { |device| device&.user&.email }

        expose(
          :phone_number,
          documentation: {
            desc: 'user\'s phone number',
            type: String
          }
        ) { |device| device&.user&.phone_number }

        expose(
          :device_id,
          documentation: {
            type: String,
            desc: 'Device id'
          }
        )

        expose(
          :device_type,
          documentation: {
            type: String,
            desc: 'Device type'
          }
        )

        expose(
          :active,
          documentation: {
            type: 'Boolean',
            desc: 'Device status'
          }
        )

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
      end
    end
  end
end
