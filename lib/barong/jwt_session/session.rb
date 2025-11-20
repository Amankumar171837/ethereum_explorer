# frozen_string_literal: true

include JWTSessions::Authorization
include JWTSessions::RailsAuthorization

module Barong
  module JWTSession
    class Session
      class << self
        def generate(payload = {}, refresh_exp = nil)
          JWTSessions::Session.new(
            payload: payload.except(:iat, :exp),
            refresh_payload: payload.except(:iat, :exp),
            access_exp: Barong::App.config.jwt_session_expire_time.to_i,
            refresh_exp: refresh_exp || Barong::App.config.jwt_refresh_expire_time.to_i,
            refresh_by_access_allowed: true
          )
        end

        def renew_session(token, payload = {})
          expiry = Barong::App.config.jwt_refresh_update_time.to_i
          session = generate(payload)
          session.update_refresh_expiry(token[:uuid], expiry)
          Barong::OpaqueJwt::Token.update_expiry(token[:uuid], expiry)
          session.renew_tokens(token[:jti], expiry)
        end
      end
    end
  end
end
