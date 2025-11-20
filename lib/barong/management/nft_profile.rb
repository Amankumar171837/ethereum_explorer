# frozen_string_literal: true

module Barong
  module Management
    class NftProfile < Management::Client

      def initialize(*)
        super ENV.fetch('PEATIO_ROOT_URL', 'http://peatio:8000'),
              Rails.configuration.x.barong_management_api_v1_configuration
      end

      def get_wonka(payload)
        self.action = :get_wonka
        jwt = generate_jwt(payload(payload))
        rest_api('/api/v2/management/wonka', params: jwt, options: { jwt: true }, method: 'post')
      end

      def get_token(payload)
        self.action = :get_token
        jwt = generate_jwt(payload(payload))
        rest_api('/api/v2/management/token', params: jwt, options: { jwt: true }, method: 'post')
      end
    end
  end
end
