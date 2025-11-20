# frozen_string_literal: true

# InfluxDB test helpers
module InfluxTestHelper
  def delete_measurments(measurement)
    Barong::Influxdb.client.query("delete from #{measurement}")
  end
end

RSpec.configure { |config| config.include InfluxTestHelper }
