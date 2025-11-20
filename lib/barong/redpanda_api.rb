module RedpandaAPI
  class << self
    def notify(event_name, event_payload)
      arguments = [event_name, event_payload]
      middlewares.each do |middleware|
        returned_value = middleware.call(*arguments)
        case returned_value
          when Array then arguments = returned_value
          else return returned_value
        end
      rescue StandardError => e
        report_exception(e)
        raise
      end
    end

    def middlewares=(list)
      @middlewares = list
    end

    def middlewares
      @middlewares ||= []
    end
  end

  module ActiveRecord
    class Mediator
      attr_reader :record

      def initialize(record)
        @record = record
      end

      def notify(partial_event_name, event_payload)
        tokens = ['model']
        tokens << record.class.topic_api_settings.fetch(:prefix) { record.class.name.underscore.gsub(/\//, '_') }
        tokens << partial_event_name.to_s
        full_event_name = record.redpanda_event_name(tokens)
        RedpandaAPI.notify(full_event_name, event_payload)
      end

      def notify_record_created
        notify(:created, record: record.as_json_for_redpanda_api.compact)
      end

      def notify_record_updated
        return if record.previous_changes.blank?

        current_record  = record
        previous_record = record.dup
        record.previous_changes.each { |attribute, values| previous_record.send("#{attribute}=", values.first) }

        # Guarantee timestamps.
        previous_record.created_at ||= current_record.created_at
        previous_record.updated_at ||= current_record.created_at

        before = previous_record.as_json_for_redpanda_api.compact
        after  = current_record.as_json_for_redpanda_api.compact

        notify :updated, \
          record:  after,
          changes: before.delete_if { |attribute, value| after[attribute] == value }
      end

      def notify_record_destroyd
        notify(:deleted, record: record.as_json_for_redpanda_api.compact)
      end
    end

    module Extension
      extend ActiveSupport::Concern

      included do
        # We add «after_commit» callbacks immediately after inclusion.
        %i[create update destroy].each do |event|
          after_commit on: event, prepend: true do
            if self.class.topic_api_settings[:on]&.include?(event)
              next if self.respond_to?(:skip_redpanda_event?) && self.skip_redpanda_event?

              redpanda_api.public_send("notify_record_#{event}d")
            end
          end
        end
      end

      module ClassMethods
        def acts_as_redpanda_eventable(settings = {})
          settings[:on] = %i[create update] unless settings.key?(:on)
          @topic_api_settings = topic_api_settings.merge(settings)
        end

        def topic_api_settings
          @topic_api_settings || superclass.instance_variable_get(:@topic_api_settings) || {}
        end
      end

      def redpanda_api
        @redpanda_api ||= Mediator.new(self)
      end

      def as_json_for_redpanda_api
        as_json
      end

      def redpanda_event_name(tokens)
        tokens.join('.')
      end
    end
  end

  # To continue processing by further middlewares return array with event name and payload.
  # To stop processing event return any value which isn't an array.
  module Middlewares

    class << self
      def application_name
        Rails.application.class.name.split('::').first.underscore
      end

      def application_version
        "#{application_name.camelize}::VERSION".constantize
      end
    end

    class IncludeEventMetadata
      def call(event_name, event_payload)
        event_payload[:name] = event_name
        [event_name, event_payload]
      end
    end

    class GenerateJWT
      def call(event_name, event_payload)
        jwt_payload = {
          iss:   Middlewares.application_name,
          jti:   SecureRandom.uuid,
          iat:   Time.now.to_i,
          exp:   Time.now.to_i + 60,
          event: event_payload
        }

        private_key = OpenSSL::PKey.read(Base64.urlsafe_decode64(Barong::App.config.redpanda_jwt_private_key))
        algorithm   = Barong::App.config.redpanda_jwt_algorithm
        jwt         = JWT::Multisig.generate_jwt jwt_payload, \
                                                   { Middlewares.application_name.to_sym => private_key },
                                                 { Middlewares.application_name.to_sym => algorithm }

        [event_name, jwt]
      end
    end

    class PrintToScreen
      def call(event_name, event_payload)
        Rails.logger.debug do
          ['',
           'Produced new event at ' + Time.current.to_s + ': ',
           'name    = ' + event_name,
           'payload = ' + event_payload.to_json,
           ''].join("\n")
        end
        [event_name, event_payload]
      end
    end

    class PublishToRedpanda
      extend Memoist

      def call(event_name, event_payload)
        Rails.logger.debug do
          "\nPublishing #{key(event_name)} (key) to #{topic_name(event_name)} (exchange name).\n"
        end
        topic = produce(event_payload.to_json, event_name)
        topic.wait
        [event_name, event_payload]
      rescue => e
        Rails.logger.warn { "Error: #{e.message}" }
      end

      private

      def panda_session
        producer = nil
        Rdkafka::Config.new(redpanda_credentials).tap do |session|
          producer = session.producer
          Kernel.at_exit { producer.close }
        end
        producer
      end
      memoize :panda_session

      def topic_config(payload, event_name)
        {
          topic:   topic_name(event_name),
          payload: payload,
          key:     key(event_name) + ".#{SecureRandom.hex(8)}"
        }
      end

      def produce(payload, event_name)
        panda_session.produce(topic_config(payload, event_name))
      end

      def redpanda_credentials
        {
          "bootstrap.servers":    Barong::App.config.redpanda_hosts,
          "debug":                Barong::App.config.redpanda_logs_level,
          "enable.partition.eof": Barong::App.config.redpanda_partition_eof,
          "sasl.username":        Barong::App.config.redpanda_sasl_username,
          "sasl.password":        Barong::App.config.redpanda_sasl_password,
          "sasl.mechanism":       Barong::App.config.redpanda_sasl_mechanism,
          "security.protocol":    Barong::App.config.redpanda_sasl_protocol
        }
      end

      def topic_name(name)
        "#{Barong::App.config.redpanda_topic_prefix}auth.events.#{name.split('.')[0..1].join('.')}"
      end

      def key(event_name)
        event_name.split('.').drop(1).join('.')
      end
    end
  end

  middlewares << Middlewares::IncludeEventMetadata.new
  middlewares << Middlewares::GenerateJWT.new
  middlewares << Middlewares::PrintToScreen.new
  middlewares << Middlewares::PublishToRedpanda.new
end
