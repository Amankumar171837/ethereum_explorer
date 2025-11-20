# encoding: UTF-8
# frozen_string_literal: true

module Redpanda
  class Config
    class <<self
      def data
        @data ||= Hashie::Mash.new(
          YAML.safe_load(
            ERB.new(File.read(Rails.root.join('config', 'redpanda.yml'))).result
          )
        )
      end

      def connect
        data[:connect]
      end

      def binding_queue(id)
        queue(data[:binding][id][:queue])[:name]
      end

      def binding_worker(id)
        ::Workers::Redpanda.const_get(id.to_s.camelize).new
      end

      def queue(id)
        data[:queue][id]
      end

      def decode_jwt(payload)
        JWT::Base64.url_decode(JSON.parse(payload)['payload'])
      end
    end
  end
end
