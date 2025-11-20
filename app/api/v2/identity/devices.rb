# frozen_string_literal: true

require_dependency 'barong/jwt'

include JWTSessions::Authorization
include JWTSessions::RailsAuthorization

module API::V2
  module Identity
    class Devices < Grape::API

      helpers do

        def set_refresh_header!
          error!({ errors: ['identity.token.not_found'] }, 404) unless headers['Refresh-Token']

          token = Barong::OpaqueJwt::Token.get_token(headers['Refresh-Token'])
          error!({ errors: ['identity.token.not_found'] }, 404) unless token

          headers['Refresh-Token'] = token
        end
      end

      resource :device do

        desc 'Refresh mining device jwt session',
             success: { code: 200, message: 'Device\'s JWT token refreshed successfully.' },
             failure: [
                        { code: 400, message: 'Required params are empty' },
                        { code: 404, message: 'Record is not found' }
                      ]
        params do
          optional :refresh_token,
                   type: String,
                   allow_blank: false,
                   desc: 'JWT Refresh token'
        end
        post 'session/refresh' do
          set_refresh_header!

          authorize_by_refresh_header!

          token   = codec.decode_token(found_token, Barong::App.config.keystore.public_key)
          user    = User.find_by_uid(token[:uid])
          error!({ errors: ['identity.session.not_found'] }, 404) unless user

          payload = codec.merge_claims(user.jwt_payload).except(:iat, :exp)
          tokens  = Barong::JWTSession::Session.renew_session(token, payload)

          tokens = Barong::OpaqueJwt::Token.set_tokens(tokens)

          header['access-token']   = tokens[:access]
          header['access-expire']  = tokens[:access_expires_at]
          header['refresh-token']  = tokens[:refresh]
          header['refresh-expire'] = tokens[:refresh_expires_at]

          status 200
        end

        desc 'Destroy mining device jwt session',
             failure: [
                        { code: 400, message: 'Required params are empty.' },
                        { code: 404, message: 'Record is not found.' }
                      ],
             success: { code: 200, message: 'Session was destroyed.' }
        params do
          requires :device_id,
                   type: String,
                   desc: 'User device id'
          optional :device_type,
                   type: String,
                   default: 'x10',
                   desc: 'Mining Device type.'
        end
        delete 'session/refresh' do
          set_refresh_header!

          authorize_by_refresh_header!

          token   = codec.decode_token(found_token, Barong::App.config.keystore.public_key)
          user    = User.find_by_uid(token[:uid])
          error!({ errors: ['identity.session.not_found'] }, 404) unless user

          JWTSessions::Session.new.flush_by_uuid(token[:uuid])

          notify_session_destroy(user.uid, 'reset_mining_device', declared(params))

          activity_record(user: user.id, action: 'logout', result: 'succeed', topic: 'Device session')

          status(200)
        end
      end
    end
  end
end
