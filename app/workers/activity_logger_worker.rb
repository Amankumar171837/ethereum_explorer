# frozen_string_literal: true

class ActivityLoggerWorker
  include Sidekiq::Worker

  def perform(params)
    Activity.create(params)
  end
end
