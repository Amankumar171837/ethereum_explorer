# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

raise "bindings must be provided." if ARGV.size == 0

logger = Rails.logger

# Create a Kafka consumer instance
consumer = nil
Rdkafka::Config.new(Redpanda::Config.connect).tap do |session|
  consumer = session.consumer
  Kernel.at_exit { consumer.close }
end

logger.info { "Connected to Redpanda" }

terminate = proc do
  puts "Terminating Redpanda consumer..."

  consumer.close

  puts "Redpanda consumer stopped."
end

at_exit { consumer.close }

Signal.trap("INT",  &terminate)
Signal.trap("TERM", &terminate)

workers = []
ARGV.each do |key|
  queue = Redpanda::Config.binding_queue(key)
  worker = Redpanda::Config.binding_worker(key)
  consumer.subscribe(queue)

  begin
    consumer.each do |message|
      puts "Received message: #{message.payload}"

      decoded_payload = Redpanda::Config.decode_jwt(message.payload)
      args            = [JSON.parse(decoded_payload)['event'].deep_symbolize_keys]

      arity           = worker.method(:process).arity
      resized_args    = arity < 0 ? args : args[0...arity]
      worker.process(*resized_args)
      # Manually commit the offset after processing the message
      consumer.store_offset(message)
    end
  rescue Rdkafka::RdkafkaError => e
    puts "Error: #{e}"
  rescue StandardError => e
    if worker.is_db_connection_error?(e)
      logger.error(db: :unhealthy, message: e.message)
      exit(1)
    end

    report_exception(e)
  end
  workers << worker
end
