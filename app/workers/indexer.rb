# frozen_string_literal: true
require 'sidekiq'

class Indexer
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(payload)
    payload = JSON.parse(payload)
    Rails.logger.debug [payload['operation'],"klass: #{payload['klass'].camelize}", "ID: #{payload['id']}"]

    record = payload['klass'].camelize.constantize.find_by(id: payload['id'])
    return if record.nil?

    case payload['operation']
    when 'index'
      record.__elasticsearch__.index_document
    when 'delete'
      begin
        record.__elasticsearch__.delete_document
      rescue Elasticsearch::Transport::Transport::Errors::NotFound
        Rails.logger.error "#{payload['klass']} not found, ID: #{payload[:id]}"
      end
    else raise ArgumentError, "Unknown operation '#{payload['operation']}'"
    end
  end
end
