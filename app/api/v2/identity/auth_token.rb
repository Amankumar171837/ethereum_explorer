# frozen_string_literal: true

module API::V2
  module Identity
    class AuthToken < Grape::API
      desc 'Generate API token for secure transaction'
      post '/generate_token' do
        token = SecureRandom.uuid
        Rails.cache.fetch("token_#{token}", expires_in: Barong::App.config.app_auth_token_lifetime.to_i.seconds) do
          params.merge!(remote_ip: remote_ip, user_agent: request.env['HTTP_USER_AGENT'])
        end
        { token: token, nonce: Time.now.to_i }
      end
    end
  end
end
