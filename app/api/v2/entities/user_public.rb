# frozen_string_literal: true

module API
  module V2
    module Entities
      class UserPublic < API::V2::Entities::Base
        expose(
          :full_name,
          documentation: {
            type: String,
            desc: 'User full name'
          }
        )

        expose(
          :username,
          documentation: {
            type: String,
            desc: 'User\'s username'
          }
        )

        expose(
          :profile_url,
          documentation: {
            type: Hash,
            desc: 'Profile picture Url'
          }
        )

        expose(
          :profile_type,
          documentation: {
            type: String,
            desc: 'Profile picture type'
          }
        )

        expose(
          :initial,
          documentation: {
            type: String,
            desc: 'Username initial'
          }
        )
      end
    end
  end
end
