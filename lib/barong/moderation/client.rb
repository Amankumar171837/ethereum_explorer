# frozen_string_literal: true

module Barong
  module Moderation
    class Client
      def aws_client
        Aws::Rekognition::Client.new(
          access_key_id: Barong::App.config.avatar_storage_access_key,
          secret_access_key: Barong::App.config.avatar_storage_secret_key,
          region: Barong::App.config.avatar_storage_region
        )
      rescue StandardError => e
        Rails.logger.error e.inspect
        error!(e.message, 422)
      end
    end
  end
end
