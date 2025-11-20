# frozen_string_literal: true

require 'faraday'
require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require 'securerandom'

module Barong
  module Management
    class Client

      extend Memoist

      attr_reader :action

      Error = Class.new(StandardError)

      class ConnectionError < Error; end

      class ResponseError < Error
        def initialize(code, msg)
          super "#{msg} (#{code})"
        end
      end

      def initialize(url, config)
        @url = url
        @security_configuration = config
      end

      def rest_api(path, params: {}, options: {}, method: 'post')
        options = { jwt: false }.merge(options)
        params = generate_jwt(payload(params)) unless options[:jwt]
        response = connection.send(method) do |req|
          req.headers = { 'Accept' => 'application/json',
                          'Content-Type' => 'application/json' }
          req.url path
          req.body = params.to_json
        end
        response = JSON.parse(response.body)
      rescue Faraday::Error => _e
        raise ConnectionError, response.body
      rescue StandardError => e
        raise Error, e
      end

      def build_path(path)
        "api/v2/management/#{path}"
      end

      def keychain(field)
        {}.tap do |h|
          @security_configuration[:keychain].each do |id, key|
            next unless action
            next unless id.in?(action[:required_signatures])
            h[id] = key[field]
          end
        end
      end

      memoize :keychain

      def payload(data)
        {
          data: data,
          iat:  Time.now.to_i,
          exp:  Time.now.to_i + 60, # TODO: Configure.
          jti:  SecureRandom.hex(12),
          iss:  'applogic'
        } # TODO: Configure.
      end

      def generate_jwt(payload)
        ::JWT::Multisig.generate_jwt(payload, keychain(:value), keychain(:algorithm))
      end

      def action=(value)
        @action = @security_configuration[:actions].fetch(value)
      end

      private

      def connection(idle_timeout = 5)
        @connection ||= Faraday.new(URI.parse(@url)) do |f|
          f.adapter :net_http, pool_size: 5, idle_timeout: idle_timeout
        end
      end
    end
  end
end
