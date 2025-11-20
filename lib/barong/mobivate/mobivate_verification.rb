# frozen_string_literal: true

require 'faraday'
require 'uri'
require 'net/http'
require 'openssl'
require 'json'

module Barong
  module Mobivate
    class MobivateVerification

      Error = Class.new(StandardError)

      class ConnectionError < Error; end

      class ResponseError < Error
        def initialize(code, msg)
          super "#{msg} (#{code})"
        end
      end

      class << self
        def send_code(params)
          rest_api('/send/single', params: params)
        end

        def rest_api(path, params: {}, method: 'post')
          response = connection.send(method) do |req|
            req.headers = { 'Accept' => 'application/json',
                            'Content-Type' => 'application/json',
                            'Authorization' => "Bearer #{Barong::App.config.mobivate_api_key}"}
            req.url path
            req.body = params.merge(routeId: Barong::App.config.mobivate_route).to_json
          end
          response = JSON.parse(response.body)
        rescue Faraday::Error => _e
          raise ConnectionError, response.body
        rescue StandardError => e
          raise Error, e
        end

        def connection(idle_timeout = 5)
          @connection ||= Faraday.new(URI.parse(ENV['MOBIVATE_URI'])) do |f|
            f.adapter :net_http, pool_size: 5, idle_timeout: idle_timeout
          end
        end
      end
    end
  end
end
