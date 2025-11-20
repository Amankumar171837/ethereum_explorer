# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module Redpanda
    class Notification < Base

      def process(payload)
        notification = ::Notification.find_by(id: payload[:notification_id])

        unless notification
          Rails.logger.info "Notification not found with id: #{payload[:notification_id]}"
          return
        end

        uid = notification.metadata[:uid]

        devices = if uid.present?
                    user = User.find_by(uid: uid)

                    unless user
                      Rails.logger.info "Skipping notification as user does not exist with uid: #{uid}"
                      return
                    end

                    user.devices.active
                  else
                    Device.active
                  end

        if devices.present?
          Rails.logger.info "Sending notification to #{devices.count} devices."

          notification.update!(metadata: notification.metadata.merge(total_devices: devices.count))

          devices.each_slice(Barong::App.config.notification_batch_size) do |batch|
            ::Redpanda::Queue.enqueue(:send_notification, { notification_id: notification.id,
                                                            device_ids: batch.pluck(:id) })
          end

          Rails.logger.info "Notifications sent successfully to the message queue."
        else
          Rails.logger.info "No active device found."
        end
      rescue => e
        Rails.logger.error("Error in sending notification: #{e.message}")

        raise e if is_db_connection_error?(e)

        report_exception(e)
      end
    end
  end
end
