# frozen_string_literal: true

module API::V2
  module Resource
    class Referral < Grape::API
      helpers ::API::V2::NamedParams

      resource :referrals do
        desc 'Returns referrals of user',
             success: API::V2::Entities::UserWithSocial,
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          optional :state,
                   type: String,
                   desc: 'Referred user\'s state'
          use :pagination_filters
        end
        get do
          referrals = current_user.referrals

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

          present referrals, with: API::V2::Entities::UserWithSocial
        end
      end
    end
  end
end
