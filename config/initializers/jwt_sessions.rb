# frozen_string_literal: true

options = if ENV.true?('BARONG_REDIS_CLUSTER')
            {
              redis_url: ENV.fetch('BARONG_REDIS_URL').split(','),
              redis_cluster: true,
              redis_password: ENV.fetch('BARONG_REDIS_PASSWORD')
            }
          else
            {
              redis_url: ENV.fetch('BARONG_JWT_REDIS_URL', 'redis://localhost:6379/0'),
            }
          end.merge!(token_prefix: 'jwt_')

JWTSessions.algorithm      = 'RS256'
JWTSessions.private_key    = Rails.application.config.x.keystore.private_key
JWTSessions.public_key     = Rails.application.config.x.keystore.private_key.public_key
JWTSessions.access_header  = 'Authorization'
JWTSessions.refresh_header = 'Refresh-Token'
JWTSessions.token_store    = :redis, options
