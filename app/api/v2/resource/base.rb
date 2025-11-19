# frozen_string_literal: true

require_dependency 'barong/middleware/jwt_authenticator'

module API::V2
  module Resource
    class Base < Grape::API
      use Barong::Middleware::JWTAuthenticator, \
        pubkey: Rails.configuration.x.keystore.public_key

      helpers API::V2::Resource::Utils

      do_not_route_options!

      mount Resource::Users
      mount Resource::Labels
      mount Resource::Profiles
      mount Resource::Phones
      mount Resource::Otp
      # mount Resource::ServiceAccounts
      mount Resource::Referral
      mount Resource::UserUpdate
      mount Resource::UserAccount
      mount Resource::EmailNotifications
      mount Resource::Devices

      add_swagger_documentation security_definitions: {
                                  'BearerToken': {
                                    description: 'Bearer Token authentication',
                                    type: 'basic',
                                    name: 'Authorization',
                                    in: 'header'
                                  }
                                }
    end
  end
end
