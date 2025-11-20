# frozen_string_literal: true

module Barong
  module OpaqueJwt
    class Token

      class << self

        def get_token(token)
          Rails.cache.read(token)
        end

        def set_tokens(tokens)
          tokens.merge(refresh: write(tokens: tokens, type: 'refresh'),
                       access: write(tokens: tokens, type: 'access'))
        end

        def update_expiry(uuid, expiry)
          Rails.cache.write(uuid, get_token(uuid), expires_in: expiry)
        end

        def get_bearer_token(token)
          _, token_value = token.to_s.split(' ')

          if token_value.length == Barong::App.config.opaque_jwt_access_length
            token_value = get_token(token_value)
          end

          token_value
        end

        private

        def write(tokens:, type:)
          key = SecureRandom.hex(32)
          Rails.cache.write(key, tokens[:"#{type}"], expires_in: tokens[:"#{type}_expires_at"] - Time.now)

          key
        end
      end
    end
  end
end
