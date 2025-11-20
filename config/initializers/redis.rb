# frozen_string_literal: true

begin
  if Rails.env.production?
    options = if ENV.true?('BARONG_REDIS_CLUSTER')
                { cluster: ENV.fetch('BARONG_REDIS_URL').split(','),password: ENV.fetch('BARONG_REDIS_PASSWORD') }
              else
                { url: ENV.fetch('BARONG_REDIS_URL', 'redis://localhost:6379/1') }
              end
    r = Redis.new(options)
    r.ping
  end
rescue Redis::CannotConnectError
  Rails.logger.fatal("Error connecting to Redis on #{redis_url} (Errno::ECONNREFUSED)")
  raise 'FATAL: connection to Redis refused'
end
