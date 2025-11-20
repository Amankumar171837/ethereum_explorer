# frozen_string_literal: true

module API::V2
  module Admin
    module Entities
      class EmailNotifications < API::V2::Entities::Base
        expose(
          :id,
          documentation: {
            type: Integer,
            desc: 'Email notification unique identifier'
          }
        )

        expose(
          :email,
          documentation: {
            type: String,
            desc: 'Email for which notification is enabled/disable.'
          }
        )

        expose(
          :uid,
          documentation: {
            desc: 'User UID.',
            type: String
          }
        ) { |en| en.user.uid }

        expose(
          :name,
          documentation: {
            type: String,
            desc: 'Email type name.'
          }
        ) { |en| en.email_type.name }

        expose(
          :description,
          documentation: {
            type: String,
            desc: 'Email type description'
          }
        ) { |en| en.email_type.description }

        expose(
          :enabled,
          documentation: {
            type: String,
            desc: 'Email Notification status (true/false)'
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
