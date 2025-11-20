# frozen_string_literal: true

require 'faraday'
require 'uri'
require 'net/http'
require 'openssl'
require 'json'

module Barong
  module Ding
    class DingApi

      Error = Class.new(StandardError)

      class ConnectionError < Error; end

      class << self
        def send_code(params)
          Rails.logger.warn { "Ding: sending OTP to #{params}" }

          rest_api('v2/verification', params: params)
        end

        def validate_code(params)
          rest_api('v2/verification/check', params: params)
        end

        def rest_api(path, params: {}, method: 'post')
          response = connection.send(method) do |req|
            req.headers = { 'Accept' => 'application/json',
                            'Content-Type' => 'application/json',
                            'Authorization' => "Bearer #{Barong::App.config.ding_api_key}" }
            req.url path
            req.body = params.to_json
          end
          response = JSON.parse(response.body)
        rescue Faraday::Error => _e
          raise ConnectionError, response.body
        rescue StandardError => e
          raise Error, e
        end

        def connection(idle_timeout = 5)
          @connection ||= Faraday.new(URI.parse(Barong::App.config.ding_api_endpoint)) do |f|
            f.adapter :net_http, pool_size: 5, idle_timeout: idle_timeout
          end
        end
      end
    end
  end
end
