# frozen_string_literal: true

module Barong
  module Management
    class User < Management::Client

      def initialize(*)
        super ENV.fetch('PEATIO_ROOT_URL', 'http://peatio:8000'),
              Rails.configuration.x.barong_management_api_v1_configuration
      end

      def check_user_status(payload)
        self.action = :check_user_status
        jwt = generate_jwt(payload(payload))
        rest_api('/api/v2/management/members/status', params: jwt, options: { jwt: true }, method: 'post')
      end

      def delete_user(payload)
        self.action = :delete_user
        jwt = generate_jwt(payload(payload))
        rest_api('/api/v2/management/members/delete', params: jwt, options: { jwt: true }, method: 'delete')
      end

      def update_user(payload)
        self.action = :update_user
        jwt = generate_jwt(payload(payload))
        rest_api('/api/v2/management/members/update', params: jwt, options: { jwt: true }, method: 'post')
      end

      def notify_session_destroy(payload)
        self.action = :notify_session_destroy
        jwt = generate_jwt(payload(payload))
        rest_api('/api/v2/management/members/mining', params: jwt, options: { jwt: true }, method: 'delete')
      end
    end
  end
end
