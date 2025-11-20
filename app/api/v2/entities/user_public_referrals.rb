# frozen_string_literal: true

module API
  module V2
    module Entities
      class UserPublicReferrals < API::V2::Entities::UserPublic
        expose :users_count,
               as: :invited,
               documentation: {
                 type: String,
                 desc: 'Referred user\'s referral count'
               }

        expose :referrals, using: Entities::UserPublic do |r|
          r.referrals.active.sample(
            rand(Barong::App.config.public_referrals_min_profile
                            .to_i..Barong::App.config.public_referrals_max_profile.to_i)
          )
        end
      end
    end
  end
end
