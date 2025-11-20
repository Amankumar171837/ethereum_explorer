# frozen_string_literal: true

# Use a dedicated redis for sidekiq as _Cluster is NOT appropriate for Sidekiq_
# https://github.com/sidekiq/sidekiq/wiki/Using-Redis#architecture
# So setting up different environment variable name for the redis client and server
# in the sidekiq configurations

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('BARONG_SIDEKIQ_REDIS_URL', 'redis://localhost:6379/1') }
  schedule_file = "config/schedule.yml"
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('BARONG_SIDEKIQ_REDIS_URL', 'redis://localhost:6379/1') }
end
