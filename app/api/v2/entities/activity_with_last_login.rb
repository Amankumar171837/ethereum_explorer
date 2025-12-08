# frozen_string_literal: true

module API::V2
  module Entities
    class ActivityWithLastLogin < API::V2::Entities::Base
      expose :user_ip,
             documentation: {
               type: 'String',
               desc: 'User IP'
             }

      expose :country,
             documentation: {
               type: 'String',
               desc: 'User country'
             }

      expose :city,
             documentation: {
               type: 'String',
               desc: 'User country'
             }

      expose :country_code,
             documentation: {
               type: 'String',
               desc: 'User country code'
             }

      expose :user_agent,
             documentation: {
               type: 'String',
               desc: 'User Browser Agent'
             }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
      end
    end
  end
end
