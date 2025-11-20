# frozen_string_literal: true

module API
  module V2
    module Entities
      # Social user info
      class UserWithSocial < API::V2::Entities::Base
        expose :full_name,
               documentation: {
                 type: String,
                 desc: 'User full name'
               }

        expose :username,
               documentation: {
                 type: String,
                 desc: 'User\'s username'
               }

        expose :profile_url,
               documentation: {
                 type: Hash,
                 desc: 'Profile picture Url'
               }

        expose :profile_type,
               documentation: {
                 type: String,
                 desc: 'Profile picture type'
               }

        expose :initial,
               documentation: {
                 type: String,
                 desc: 'Username initial'
               }

        expose :users_count,
               as: :referrals,
               documentation: {
                 type: String,
                 desc: 'Referred user\'s referral count'
               }

        expose :state,
               documentation: {
                 type: String,
                 desc: 'User\'s state'
               }

        expose :created_at,
               as: :joining_date,
               documentation: {
                 type: Date,
                 desc: 'User\'s joining date'
               } do |u|
                 u.created_at.to_date
               end
      end
    end
  end
end
