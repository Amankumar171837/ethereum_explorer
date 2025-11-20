# frozen_string_literal: true
require 'sidekiq'

class InfluxWriterWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'influx'

  def perform(payload)
    payload = JSON.parse(payload)
    record = payload['klass'].classify.constantize.find_by(id: payload['id'])
    record.write_to_influx unless record.nil?
  end
end

