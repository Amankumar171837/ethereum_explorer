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
          :verified,
          documentation: {
            type: String,
            desc: 'User\'s KYC status.'
          }
        )

        expose(
          :is_blue_verified,
          documentation: {
            type: String,
            desc: 'User\'s blue verified'
          }
        )

        expose(
          :l2,
          documentation: {
            type: String,
            desc: 'User\'s blue verified data'
          },
          if: lambda { |_, options| options[:levels] == true }
        )

        expose(
          :l3,
          documentation: {
            type: String,
            desc: 'User\'s level 3 details'
          },
          if: lambda { |_, options| options[:levels] == true }
        )

        expose(
          :l4,
          documentation: {
            type: String,
            desc: 'User\'s level 4 details'
          },
          if: lambda { |_, options| options[:levels] == true }
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
