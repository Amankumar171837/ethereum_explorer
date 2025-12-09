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

      expose :level,
             documentation: {
                 type: 'Integer',
                 desc: 'User level'
             }

      expose :profile_url,
             documentation: {
                 type: 'Hash',
                 desc: 'Profile picture Url'
             }

      expose :profile_type,
             documentation: {
                 type: String,
                 desc: 'Profile picture type'
             }

      expose :country,
             documentation: {
                 desc: 'User country',
                 type: String
             }

      expose :data,
             documentation: {
                 type: 'String',
                 desc: 'Additional phone and profile info'
             }

      expose :referral_code,
             documentation: {
                 desc: 'User unique referral code.',
                 type: String
             }

      expose :password_enabled,
             as: :login_via_password,
             documentation: {
                 desc: 'User can login via password or not.',
                 type: String
             }

      expose(
          :without_social_profile,
          as: :profiles,
          using: Entities::Profile
      )

      expose :profiles, using: Entities::Profile
    end
  end
end
