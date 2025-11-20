# frozen_string_literal: true

module API::V2
  module Resource
    class UserProfiles < Grape::API

      resource :profile do
        desc 'Set Nfe as profile for current user',
             success: { code: 201, message: 'Profile picture is uploaded' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :token,
                   type: String,
                   desc: 'Token code'
        end
        post '/token-media' do
          response = Barong::Management::NftProfile
                       .new.get_token({ code: params[:token],
                                        uid: current_user.uid }).deep_symbolize_keys!

          error!({ errors: ['token.media.response_error'] }, 422) unless response[:url].present?

          media = current_user.medias.new(image_urls: response, type: 'token')
          code_error!(media.errors.details, 422) unless media.save

          present current_user.profile_url
        rescue => e
          Rails.logger.error "Media create error: #{e}"
          error!({ errors: ['resource.media.create_error'] }, 422)
        end

        desc 'Set Wonka as profile for current user',
             success: { code: 201, message: 'Profile picture is uploaded' },
             failure: [
               { code: 400, message: 'Required params are empty' },
               { code: 401, message: 'Invalid bearer token' },
               { code: 422, message: 'Validation errors' }
             ]
        params do
          requires :wonka,
                   type: String,
                   desc: 'WonkaBot code'
        end
        post '/wonka-media' do
          response = Barong::Management::NftProfile
                       .new.get_wonka({ wonka_token: params[:wonka],
                                        uid: current_user.uid }).deep_symbolize_keys!

          error!({ errors: ['wonka.media.response_error'] }, 422) unless response[:url].present?

          media = current_user.medias.new(image_urls: response, type: 'wonka')
          code_error!(media.errors.details, 422) unless media.save

          present current_user.profile_url
        rescue => e
          Rails.logger.error "Media create error: #{e}"
          error!({ errors: ['resource.media.create_error'] }, 422)
        end
      end
    end
  end
end
