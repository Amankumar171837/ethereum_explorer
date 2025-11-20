# frozen_string_literal: true

require 'faraday'
require 'uri'
require 'net/http'
require 'openssl'
require 'json'

module Barong
  module MailerLite
    class Client

      Error = Class.new(StandardError)

      class ConnectionError < Error; end

      class ResponseError < Error
        def initialize(code, msg)
          super "#{msg} (#{code})"
        end
      end

      def rest_api(path, params: {}, method: 'post')
        response = connection.send(method) do |req|
          req.headers = { 'Accept' => 'application/json',
                          'Content-Type' => 'application/json',
                          'X-MailerLite-ApiKey' => Barong::App.config.mailer_lite_api_token }
          req.url path
          req.body = params.to_json
        end
        response = JSON.parse(response.body)
      rescue Faraday::Error => _e
        raise ConnectionError, response.body
      rescue StandardError => e
        raise Error, e
      end

      private

      def connection(idle_timeout = 5)
        @connection ||= Faraday.new(URI.parse(Barong::App.config.mailer_lite_uri)) do |f|
          f.adapter :net_http, pool_size: 5, idle_timeout: idle_timeout
        end
      end
    end
  end
end
