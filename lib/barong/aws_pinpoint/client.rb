# frozen_string_literal: true

module Barong
  module AwsPinpoint
    class Client
      def aws_client
        Aws::Pinpoint::Client.new(
          access_key_id: Barong::App.config.aws_pinpoint_access_key,
          secret_access_key: Barong::App.config.aws_pinpoint_secret_key,
          region: Barong::App.config.aws_pinpoint_storage_region
        )
      rescue StandardError => e
        Rails.logger.error e.inspect
        error!(e.message, 422)
      end
    end
  end
end
