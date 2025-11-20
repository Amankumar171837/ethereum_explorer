# frozen_string_literal: true

module API::V2::Admin
  module Entities
    class UserStateChangeLogs < API::V2::Entities::Base
      expose :past_state,
             documentation: {
              type: 'String',
              desc: 'User Previous State'
             }

      expose :state,
             documentation: {
              type: 'String',
              desc: 'User changed_to State'
             }

      expose :remark,
             documentation: {
              type: 'String',
              desc: 'Remark'
             }

      expose :change_by_user_email,
             documentation: {
              type: 'String',
              desc: 'Email of the Admin that did the changes' 
             }

      expose :change_by_user_uid,
             documentation: {
              type: 'String',
              desc: 'UID of the Admin that did the changes'
             }

      with_options(format_with: :iso_timestamp) do
        expose :created_at
      end
    end
  end
end
