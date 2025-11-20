# encoding: UTF-8
# frozen_string_literal: true

module Redpanda
  class Queue

    class << self

      def generate_jwt(event_payload)
        jwt_payload = {
          iss:   application_name,
          jti:   SecureRandom.uuid,
          iat:   Time.now.to_i,
          exp:   Time.now.to_i + 60,
          event: event_payload
        }

        private_key = OpenSSL::PKey.read(Base64.urlsafe_decode64(Barong::App.config.redpanda_jwt_private_key))
        algorithm   = Barong::App.config.redpanda_jwt_algorithm
        JWT::Multisig.generate_jwt jwt_payload, \
                                     { application_name.to_sym => private_key },
                                   { application_name.to_sym => algorithm }
      end

      def application_name
        Rails.application.class.name.split('::').first.underscore
      end

      def topic_config(payload, queue)
        {
          topic:   queue[:name],
          payload: generate_jwt(payload).to_json,
          key:     queue[:key] + ".#{SecureRandom.hex(8)}"
        }
      end

      def enqueue(id, payload)
        queue =  Redpanda::Config.queue(id)
        connection.produce(topic_config(payload, queue))
      end

      private

      def connection
        @connection ||=  Rdkafka::Config.new(Redpanda::Config.connect).producer
      end
    end
  end
end
