# frozen_string_literal: true

module API
  module V2
    module Admin
      # Admin functionality over permissions table
      class Referral < Grape::API
        resource :referrals do
          helpers ::API::V2::NamedParams
          helpers ::API::V2::Admin::NamedParams

          desc 'get the referrals list for a user',
          failure: [
            { code: 401, message: 'Invalid bearer token' },
          ],
            success: API::V2::Admin::Entities::User
          params do
            requires :uid,
                     type: String,
                     desc: 'The shared user ID.'
            optional :state,
                     type: String,
                     desc: 'Referral state'
            use :pagination_filters
          end
          get do
            admin_authorize! :read, User

            user = User.find_by(uid: params[:uid])
            error!({ errors: ['admin.user.doesnt_exists'] }, 422) unless user

            referrals = user.referrals

            if params[:state] == 'pending'
              referrals = paginate(referrals.where(state: 'pending'))
            else
              if referrals.present?
                referrals = paginate(referrals)
                status = fetch_mining_status(referrals.pluck(:uid))

                if status.present?
                  referrals.each do |ref|
                    if ref.state == 'active' && !status[ref.uid]
                      ref.state = 'inactive'
                    end
                  end
                end
              end
            end

            present referrals, with: API::V2::Admin::Entities::User
          end
        end
      end
    end
  end
end
