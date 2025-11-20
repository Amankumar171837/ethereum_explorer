# frozen_string_literal: true

module API
  module V2
    module Resource
      class EmailNotifications < Grape::API
        resource :email do

          desc 'Get all Email Types'
          get 'notifications' do
            data = EmailType.active.each_with_object([]) do |type, result|
                     notification = current_user.email_notification(type.name)
                     result << type.slice(:name, :description)
                                 .merge(enabled: notification&.enabled? || notification.nil?)
                   end
            present data
          end

          desc "Update Email notification for a user."
          params do
            requires :email_type,
                     type: String,
                     desc: 'Email type name.'
            requires :enabled,
                     type: Boolean,
                     desc: 'Email Notification flag.'
          end
          post 'notifications' do
            email_type = ::EmailType.active.find_by(name: params[:email_type])
            error!({ errors: ['resource.email_type.not_found'] }, 422) unless email_type

            notification = current_user.email_notifications.find_or_initialize_by(email: current_user.email,
                                                                                  email_type: email_type)
            notification.update!(enabled: params[:enabled])

            status 201
          rescue => e
            Rails.logger.error "Email Notification update error: #{e.inspect}"
            error!({ errors: ['resource.email_notifications.update_error'] }, 422)
          end
        end
      end
    end
  end
end
