# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module Redpanda
    class SendNotification < Base

      def process(payload)
        devices = Device.where(id: payload[:device_ids])

        notification = ::Notification.find_by(id: payload[:notification_id])

        unless devices.present? && notification
          Rails.logger.info "Returning as total devices: #{devices.count}, notification id: #{payload[:notification_id]}"
          return
        end

        devices.each do |device|
          next unless device.device_token.present?

          FCMService.new.push_to_device(token: device.device_token,
                                        title: notification.title,
                                        body: notification.body)
          create_record(device, notification, 'success')
        rescue => e
          Rails.logger.error("Error sending notification: device: #{device.device_id}, #{e.message}")
          create_record(device, notification, 'failed', e)
          next
        end
      end

      def create_record(device, notification, status, error = nil)
        notification.notification_recipients.create!(device: device, user: device.user, status: status,
                                                     metadata: error.present? ? { error: error.to_s } : {})
      end
    end
  end
end
