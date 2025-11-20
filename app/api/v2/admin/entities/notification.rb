# frozen_string_literal: true

module API::V2
  module Admin
    module Entities
      class Notification < API::V2::Entities::Base
        expose(
          :id,
          documentation: {
            type: Integer,
            desc: 'Notification unique identifier.'
          }
        )

        expose(
          :title,
          documentation: {
            type: String,
            desc: 'Notification title.'
          }
        )

        expose(
          :body,
          documentation: {
            type: String,
            desc: 'Notification body.'
          }
        )

        expose(
          :metadata,
          documentation: {
            type: JSON,
            desc: 'Notification metadata.'
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
