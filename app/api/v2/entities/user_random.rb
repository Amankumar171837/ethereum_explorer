# frozen_string_literal: true

module API
  module V2
    module Entities
      class UserRandom < API::V2::Entities::Base
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
        ) { |u| u.profile_url&.url(:small) }

        expose(
          :profile_type,
          documentation: {
            type: String,
            desc: 'Profile picture type'
          }
        )
      end
    end
  end
end
