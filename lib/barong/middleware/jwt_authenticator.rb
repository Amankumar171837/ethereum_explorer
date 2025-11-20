# frozen_string_literal: true

module Barong
  module Middleware
    # Authenticate a user by a bearer token
    class JWTAuthenticator < Grape::Middleware::Base
      def initialize(app, options)
        super(app, options)
        raise(Peatio::Auth::Error, 'Public key missing') unless options[:pubkey]

        @keypub = options[:pubkey]
      end

      def before
        return if request.path.include? 'swagger'

        raise(Peatio::Auth::Error, 'Header Authorization missing') \
          unless authorization_present?

        token_value = Barong::OpaqueJwt::Token.get_bearer_token(request.headers['Authorization'])

        jwt_session.send(:access_token_data, token_value) if authenticator.decode(token_value).has_key?(:ruuid)
        env[:current_payload] = authenticator.authenticate!('Bearer ' + token_value)
      end

      private

      # JWT Authenticator instance from peatio-core
      #
      # @return [Peatio::Auth::JWTAuthenticator]
      def authenticator
        @authenticator ||=
          Peatio::Auth::JWTAuthenticator.new(@keypub)
      end

      def jwt_session
        @jwt_session ||= JWTSessions::Session.new
      end

      def authorization_present?
        request.headers.key?('Authorization')
      end

      # Request entity
      #
      # @return [Grape::Request]
      def request
        @request ||= Grape::Request.new(env)
      end
    end
  end
end
