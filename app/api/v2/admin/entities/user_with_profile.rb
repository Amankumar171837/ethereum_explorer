# frozen_string_literal: true

module API::V2::Admin
  module Entities
    class UserWithProfile < API::V2::Entities::UserWithProfile
      expose :email,
             documentation: {
               type: 'String',
               desc: 'User Email'
             }

      expose :referral_of,
             documentation: {
               type: 'String',
               desc: 'Referrer user UID'
             } do |u|
        ::User.find_by(id: u.referral_id)&.uid
      end

      expose :users_count,
             as: :referrals,
             documentation: {
               type: String,
               desc: 'Referred user\'s referral count'
             }

      expose :social_media_status,
             documentation: {
               type: String,
               desc: 'User\'s social media status'
             }

      expose :profiles, using: Entities::Profile
    end
  end
end
