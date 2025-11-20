# frozen_string_literal: true

module API
  module V2
    module Admin
      class EmailNotifications < Grape::API

        resource 'email-notifications' do

          helpers ::API::V2::Admin::NamedParams

          desc 'Get all Email Notifications',
               success: Entities::EmailNotifications,
               failure: [
                          { code: 401, message: 'admin.email_notifications.invalid.token' }
                        ]
          params do
            optional :id,
                     type: Integer,
                     desc: 'Email Notification unique identifier'
            optional :uid,
                     type: String,
                     desc: 'UID of a user'
            optional :email,
                     type: String,
                     desc: 'Email of a user'
            optional :email_type_id,
                     type: Integer,
                     desc: 'Email type unique identifier'
            optional :enabled,
                     type: Boolean,
                     desc: 'User email notification (true/false)'
            optional :ordering,
                     values: { value: -> (p){ %w[asc desc].include?(p) }, message: 'user.ordering.invalid_ordering' },
                     default: 'asc',
                     desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
            optional :order_by,
                     default: 'id',
                     desc: 'Name of the field, which result will be ordered by.'
            use :pagination_filters
          end
          get do
            admin_authorize! :read, EmailNotification

            user = User.find_by(uid: params[:uid]) if params[:uid].present?

            EmailNotification.order("#{params[:order_by]} #{params[:ordering]}")
              .tap { |q| q.where!(id: params[:id]) if params[:id] }
              .tap { |q| q.where!(user: user) if params[:uid] }
              .tap { |q| q.where!(email: params[:email]) if params[:email] }
              .tap { |q| q.where!(email_type_id: params[:email_type_id]) if params[:email_type_id] }
              .tap { |q| q.where!(enabled: params[:enabled]) unless params[:enabled].nil? }
              .tap { |q| present paginate(q), with: Entities::EmailNotifications }
          end

          desc "Update Email notification for a user."
          params do
            requires :id,
                     type: String,
                     desc: 'Email Notification unique identifier.'
            requires :enabled,
                     type: Boolean,
                     desc: 'User email notification (true/false)'
          end
          post do
            admin_authorize! :update, EmailNotification

            notification = EmailNotification.find_by(id: params[:id])
            error!({ errors: ['admin.email_notification.not_found'] }, 422) unless notification

            notification.update!(enabled: params[:enabled])

            present notification, with: Entities::EmailNotifications
          rescue => e
            Rails.logger.error "Email Notification update error: #{e.inspect}"
            error!({ errors: ['resource.email_notifications.update_error'] }, 422)
          end
        end
      end
    end
  end
end
