# frozen_string_literal: true

require 'faraday'
require 'uri'
require 'net/http'
require 'openssl'
require 'json'

module Barong
  module Bulkgate
    class BulkgateVerification

      Error = Class.new(StandardError)

      class ConnectionError < Error; end

      class ResponseError < Error
        def initialize(code, msg)
          super "#{msg} (#{code})"
        end
      end

      class << self
        def send_code(params)
          rest_api('/api/1.0/simple/transactional', params: params)
        end

        def rest_api(path, params: {}, method: 'post')
          response = connection.send(method) do |req|
            req.headers = { 'Accept' => 'application/json',
                            'Content-Type' => 'application/json' }
            req.url path
            req.body = params.merge(application_id: Barong::App.config.bulkgate_application_id,
                                    application_token: Barong::App.config.bulkgate_application_token).to_json
          end
          response = JSON.parse(response.body)
        rescue Faraday::Error => _e
          raise ConnectionError, response.body
        rescue StandardError => e
          raise Error, e
        end

        def connection(idle_timeout = 5)
          @connection ||= Faraday.new(URI.parse(ENV['BULKGATE_URI'])) do |f|
            f.adapter :net_http, pool_size: 5, idle_timeout: idle_timeout
          end
        end
      end
    end
  end
end
