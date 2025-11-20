# frozen_string_literal: true

require_dependency 'barong/jwt'

include JWTSessions::Authorization
include JWTSessions::RailsAuthorization

module API::V2
  module Resource
    class Devices < Grape::API

      helpers Identity::SecurityUtils

      resource :device do

        desc 'Generate tokens for the device.',
             success: { code: 200, message: 'User authorization' },
             failure: [
                        { code: 400, message: 'Required params are empty' },
                        { code: 404, message: 'Record is not found' }
                      ]
        params do
          requires :uid,
                   type: String,
                   desc: 'Current user uid.'
          requires :device_id,
                   type: String,
                   desc: 'X10 Device id'
          requires :device_type,
                   type: String,
                   desc: 'Device type'
        end
        post '/connect' do
          validate_signature?('x10_connect')

          payload = codec.merge_claims(current_user.jwt_payload).except(:iat, :exp)
          tokens = Barong::JWTSession::Session.generate(payload, Barong::App.config.device_jwt_refresh_exp_time.to_i).login

          tokens = Barong::OpaqueJwt::Token.set_tokens(tokens)

          header['access-token']   = tokens[:access]
          header['access-expire']  = tokens[:access_expires_at]
          header['refresh-token']  = tokens[:refresh]
          header['refresh-expire'] = tokens[:refresh_expires_at]

          status 200
        rescue StandardError => e
          Rails.logger.error e.inspect
          error!(e.message, 422)
        end
      end
    end
  end
end
