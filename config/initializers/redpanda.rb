# frozen_string_literal: true

require_dependency 'barong/redpanda_api'

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.include ::RedpandaAPI::ActiveRecord::Extension
end
