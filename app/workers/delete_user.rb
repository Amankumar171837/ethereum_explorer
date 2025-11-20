require 'sidekiq'

class DeleteUser
  include Sidekiq::Worker
  sidekiq_options queue: 'cron'

  def perform
    users = User.where('social_media_status IN (?) AND status_updated_at <= ?',
                       %w[deleted deactivated], Barong::App.config.account_delete_period.days.ago)
    return unless users.present?

    users.each do |user|
      ActiveRecord::Base.transaction do
        Barong::Management::User.new.delete_user({ uid: user.uid })
        user.destroy

        Rails.logger.info("User with UID: #{user.uid} have been deleted successfully")
      end
    end
  rescue => e
    Rails.logger.error("Error destroying record: #{e.message}")
    raise e
  end
end
