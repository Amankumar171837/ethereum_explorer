# frozen_string_literal: true

module API::V2
  module Public
    class Users < Grape::API

      helpers API::V2::NamedParams

      helpers do
        def validate_user!(params)
          user = User.find_by(username: params[:username])
          error!({ errors: ['public.user.does_not_exist'] }, 422) unless user && (user.state == 'active')

          user
        end
      end
      namespace :users do

        desc 'get user\'s referrals with username',
             success: API::V2::Entities::UserPublic
        params do
          requires :username,
                   type: String,
                   desc: 'User\'s username'
          use :pagination_filters
        end
        get 'referrals' do
          user = validate_user!(params)

          present paginate(user.referrals.active), with: API::V2::Entities::UserPublic
        end
      end
    end
  end
end
