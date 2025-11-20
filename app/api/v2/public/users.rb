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
        desc 'get user public info with username',
             success: API::V2::Entities::UserPublicReferrals, levels: true
        params do
          requires :username,
                    type: String,
                    desc: 'User\'s username'
        end
        get do
          user = validate_user!(params)

          present user, with: API::V2::Entities::UserPublicReferrals, levels: true
        end

        desc 'get user public info with username from elasticsearch',
             success: API::V2::Entities::UserWithPublicReferrals, levels: true
        params do
          requires :username,
                   type: String,
                   desc: 'User\'s username'
        end
        get '/search' do
          user = User.search_query(params)

          present user[:records], with: API::V2::Entities::UserWithPublicReferrals, levels: true
        end

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

        desc 'get newly random user',
             success: API::V2::Entities::UserPublic
        get 'random' do
          user = Rails.cache.fetch('random_user_api_xyz', expires_in: 3.seconds) do
                   User.active.where('LENGTH(username) <= 10').last(100_00).sample
                 end

          present user, with: API::V2::Entities::UserPublic
        end
      end
    end
  end
end
