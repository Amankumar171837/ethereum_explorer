# frozen_string_literal: true

module API
  module V2
    module Entities
      class UserWithUsername < API::V2::Entities::Base
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

        expose(
          :verified,
          documentation: {
            type: Hash,
            desc: 'User\'s KYC status.'
          }
        )

        expose(
          :is_blue_verified,
          documentation: {
            type: Hash,
            desc: 'User\'s referrals'
          }
        )
      end
    end
  end
end
