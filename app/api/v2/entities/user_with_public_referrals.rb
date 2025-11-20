# frozen_string_literal: true

module API
  module V2
    module Entities
      class UserWithPublicReferrals < API::V2::Entities::UserPublic
        expose :users_count,
               as: :invited,
               documentation: {
                 type: String,
                 desc: 'Referred user\'s referral count'
               }

        expose :referrals, using: Entities::UserPublic do |r|
          r.get_referrals
        end
      end
    end
  end
end
