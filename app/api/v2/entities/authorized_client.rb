# frozen_string_literal: true

module API::V2
  module Entities
    class AuthorizedClient < API::V2::Entities::Base
      expose(
        :registered_client,
        documentation: {
          type: String,
          desc: 'Registered Client name'
        }
      ) { |client| client.registered_client.name }

      with_options(format_with: :iso_timestamp) do
        expose :connected_at
        expose :created_at
        expose :updated_at
      end
    end
  end
end
