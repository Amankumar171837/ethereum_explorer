module API::V2
  module Entities
    class ReferralCode < API::V2::Entities::Base

      expose :referral_code,
             documentation: {
               type: 'String',
               desc: 'referral code of user'
             }

      expose :username,
             documentation: {
               type: 'String',
               desc: 'User\'s username'
             }
    end
  end
end
