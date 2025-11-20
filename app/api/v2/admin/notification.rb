# frozen_string_literal: true

module API
  module V2
    module Admin
      class Notification < Grape::API

        helpers ::API::V2::Admin::NamedParams

        namespace :notifications do
          desc 'Get all Notifications.',
               success: Entities::Notification,
               failure: [
                          { code: 401, message: 'admin.notifications.invalid.token' }
                        ]
          params do
            optional :id,
                     type: Integer,
                     desc: 'Notification unique identifier'
            optional :ordering,
                     values: { value: -> (p){ %w[asc desc].include?(p) },
                               message: 'notification.ordering.invalid_ordering' },
                     default: 'asc',
                     desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
            optional :order_by,
                     default: 'id',
                     desc: 'Name of the field, which result will be ordered by.'
            use :pagination_filters
          end
          get do
            admin_authorize! :read, ::Notification

            ::Notification.order("#{params[:order_by]} #{params[:ordering]}")
              .tap { |q| q.where!(id: params[:id]) if params[:id] }
              .tap { |q| present paginate(q), with: Entities::Notification }
          end

          desc 'Get all Notification recipients.',
               success: Entities::NotificationRecipient,
               failure: [
                          { code: 401, message: 'admin.notifications_recipients.invalid.token' }
                        ]
          params do
            optional :id,
                     type: Integer,
                     desc: Entities::NotificationRecipient.documentation[:id][:desc]
            optional :uid,
                     type: String,
                     desc: Entities::NotificationRecipient.documentation[:uid][:desc]
            optional :notification_id,
                     type: String,
                     desc: 'Notification id.'
            optional :status,
                     type: String,
                     desc: Entities::NotificationRecipient.documentation[:status][:desc]
            optional :ordering,
                     values: { value: -> (p){ %w[asc desc].include?(p) }, message: 'user.ordering.invalid_ordering' },
                     default: 'asc',
                     desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
            optional :order_by,
                     default: 'id',
                     desc: 'Name of the field, which result will be ordered by.'
            use :pagination_filters
          end
          get 'recipients' do
            admin_authorize! :read, NotificationRecipient

            user = User.find_by(uid: params[:uid]) if params[:uid].present?

            NotificationRecipient.order("#{params[:order_by]} #{params[:ordering]}")
              .tap { |q| q.where!(id: params[:id]) if params[:id] }
              .tap { |q| q.where!(user: user) if params[:uid] }
              .tap { |q| q.where!(notification_id: params[:notification_id]) if params[:notification_id] }
              .tap { |q| q.where!(status: params[:status]) if params[:status] }
              .tap { |q| present paginate(q), with: Entities::NotificationRecipient }
          end
        end

        desc 'Push custom notification'
        params do
          optional :uid,
                   type: String,
                   desc: 'user\'s uid'
          requires :title,
                   type: String,
                   allow_blank: false,
                   desc: 'Notification title'
          requires :message,
                   type: String,
                   allow_blank: false,
                   desc: 'Notification message.'
        end
        post 'notification/push' do
          admin_authorize! :update, ::Notification

          notification = ::Notification.create!(title: params[:title],
                                                body: params[:message],
                                                metadata: { uid: params[:uid] }.compact)

          Redpanda::Queue.enqueue(:notification, { notification_id: notification.id })

          present notification, with: Entities::Notification
        rescue StandardError => e
          Rails.logger.error "Failed to create notification: #{e.inspect}"
          error!({ errors: ['admin.notification.create_error'] }, 422)
        end
      end
    end
  end
end
