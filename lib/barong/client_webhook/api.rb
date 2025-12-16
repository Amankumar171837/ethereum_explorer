# frozen_string_literal: true

require 'faraday'
require 'uri'
require 'net/http'
require 'openssl'
require 'json'

module Barong
  module ClientWebhook
    class Api

      Error = Class.new(StandardError)

      class ConnectionError < Error; end

      class << self
        def update_user(url, params, signature)
          rest_api(url, params: params, signature: signature)
        end

        def rest_api(url, params: {}, signature:, method: 'post')
          response = connection(url).send(method) do |req|
            req.headers = { 'Accept' => 'application/json',
                            'Content-Type' => 'application/json',
                            'Signature' => signature }
            req.body = params.to_json
          end

          {
            status: response.status,
            body: response.body.present? ? JSON.parse(response.body) : nil
          }
        rescue Faraday::Error => _e
          raise ConnectionError, response.body
        rescue StandardError => e
          raise Error, e
        end

        def connection(url, idle_timeout = 5)
          @connection ||= Faraday.new(url) do |f|
            f.adapter :net_http, pool_size: 5, idle_timeout: idle_timeout
          end
        end
      end
    end
  end
end
