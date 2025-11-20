# frozen_string_literal: true

module Barong
  module MailerLite
    class MailerLite

      def initialize
        @client = nil
      end

      def send_details(payload)
        client.rest_api("/api/v2/groups/#{Barong::App.config.mailer_lite_group_id}/subscribers",
                        params: payload, method: 'post')
      end

      private

      def client
        @client ||= Barong::MailerLite::Client.new
      end
    end
  end
end
