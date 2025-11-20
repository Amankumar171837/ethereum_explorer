# frozen_string_literal: true

module API::V2
  module Admin
    module Entities
      class NotificationRecipient < API::V2::Entities::Base
        expose(
          :id,
          documentation: {
            type: Integer,
            desc: 'Notification unique identifier.'
          }
        )

        expose(
          :uid,
          documentation: {
            type: String,
            desc: 'User\'s uid.'
          }
        ) { |notif| notif.user.uid }

        expose(
          :phone_number,
          documentation: {
            type: String,
            desc: 'User\'s phone number.'
          }
        ) { |notif| notif.user.phone_number }

        expose(
          :device_id,
          documentation: {
            type: String,
            desc: 'Notification device id.'
          }
        ) { |notif| notif.device.device_id }

        expose(
          :device_type,
          documentation: {
            type: String,
            desc: 'Notification device type.'
          }
        ) { |notif| notif.device.device_type }

        expose(
          :notification,
          documentation: {
            type: String,
            desc: 'Notification details.'
          }
        )

        expose(
          :metadata,
          documentation: {
            type: JSON,
            desc: 'Notification recipient metadata'
          }
        )

        expose(
          :status,
          documentation: {
            type: String,
            desc: 'Notification delivery status.'
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
