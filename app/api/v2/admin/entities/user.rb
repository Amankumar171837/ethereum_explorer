# frozen_string_literal: true

module API::V2::Admin
  module Entities
    class User < API::V2::Entities::User
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

      expose :social_media_status,
             documentation: {
               type: String,
               desc: 'User\'s social media status'
             }
    end
  end
end
