# frozen_string_literal: true

require 'faraday'
require 'uri'
require 'net/http'
require 'openssl'
require 'json'

module Barong
  module Smsala
    class SmsalaApi

      Error = Class.new(StandardError)

      class ConnectionError < Error; end

      class << self
        def send_code(params)
          rest_api('api/SendSMS', params: params)
        end

        def rest_api(path, params: {}, method: 'post')
          unless params[:sender_id].present?
            params[:sender_id] = 'KONSEL'
          end
          response = connection.send(method) do |req|
            req.headers = { 'Accept' => 'application/json',
                            'Content-Type' => 'application/json' }
            req.url path
            req.body = params.merge(api_id: Barong::App.config.smsala_api_id,
                                    api_password: Barong::App.config.smsala_api_password,
                                    callback_url: Barong::App.config.smsala_callback_url).to_json
          end
          response = JSON.parse(response.body)
        rescue Faraday::Error => _e
          raise ConnectionError, response.body
        rescue StandardError => e
          raise Error, e
        end

        def connection(idle_timeout = 5)
          @connection ||= Faraday.new(URI.parse(ENV['SMSALA_API_URL'])) do |f|
            f.adapter :net_http, pool_size: 5, idle_timeout: idle_timeout
          end
        end
      end
    end
  end
end
