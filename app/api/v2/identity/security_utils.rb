# frozen_string_literal: true

module API::V2
  module Identity
    module SecurityUtils
      def validate_signature?(path = nil)
        verifier = RequestVerifier.new(app_headers.merge!(endpoint: path), params)
        # Validate remote ip for generated token, user agent and device details
        error!({ errors: ['authz.invalid_request_headers'] }, 401) unless validate_remote_ip && validate_user_agent && validate_device

        # validate that nonce is a positive integer
        error!({ errors: ['authz.nonce_not_valid_timestamp'] }, 401) if app_headers[:nonce].to_i <= 0

        # timestamp_window is a difference between server_time and nonce creation time
        nonce_timestamp_window = ((Time.now.to_f * 1000).to_i - (app_headers[:nonce].to_i * 1000)).abs
        Rails.logger.debug("Api key authorization via key: #{app_headers[:token]} to path #{request.env['REQUEST_PATH']} \
                          with nonce: #{app_headers[:nonce]} in a window of #{nonce_timestamp_window}")
        # (server_time - nonce) should not be more than nonce lifetime
        error!({ errors: ['authz.nonce_expired'] }, 401) if nonce_timestamp_window >= Barong::App.config.app_auth_nonce_lifetime
        # signature should be valid
        error!({ errors: ['authz.invalid_signature'] }, 401) unless verifier.verify_hmac_payload?
      end

      def validate_remote_ip
        token_data.dig(:remote_ip) == remote_ip
      end

      def validate_user_agent
        token_data.dig(:user_agent) == request.env['HTTP_USER_AGENT']
      end

      def validate_device
        token_data.dig(:device_id) == params[:device_id] && token_data.dig(:device_type) == params[:device_type]
      end

      def token_data
        Rails.cache.read("token_#{app_headers[:token]}") || {}
      end

      def app_headers
        {
          nonce: request.headers['X-App-Auth-Nonce'],
          signature: request.headers['X-App-Auth-Signature'],
          token: request.headers['X-App-Auth-Token'],
          user_agent: request.env['HTTP_USER_AGENT'],
          verb: request.env['REQUEST_METHOD']
        }
      end
    end
  end
end
