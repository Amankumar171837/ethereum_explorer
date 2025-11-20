require 'sidekiq'

class UpdateUserMetrics
  include Sidekiq::Worker
  sidekiq_options queue: 'metrics_cron'

  def perform
    Rails.cache.fetch('all_metrics', expires_in: 900) do
      Rails.logger.info 'Update cache for user metrics.'

      Activity.fetch_all_data('', '')
    end
  rescue => e
    Rails.logger.error("Error destroying record: #{e.message}")
    raise e
  end
end
