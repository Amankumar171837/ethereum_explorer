# frozen_string_literal: true

module API::V2
  module Admin
    module Entities
      class EmailTypes < API::V2::Entities::Base
        expose(
          :id,
          documentation: {
            type: Integer,
            desc: 'Email type unique identifier'
          }
        )

        expose(
          :name,
          documentation: {
            type: String,
            desc: 'Email type name.'
          }
        )

        expose(
          :description,
          documentation: {
            type: String,
            desc: 'Email type description'
          }
        )

        expose(
          :status,
          documentation: {
            type: String,
            desc: 'Email type status (true/false)'
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
