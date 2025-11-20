# encoding: UTF-8
# frozen_string_literal: true

module InfluxHelper
  extend ActiveSupport::Concern

  included do
    def write_to_influx(tp = 's')
      Barong::Influxdb.client.write_point(self.class.table_name.to_s, influx_data, 'ns')
    end

    def create_record_in_influx_db
      ::InfluxWriterWorker.perform_async({ id: id, klass: self.class.table_name.to_s }.to_json)
    end

    class << self
      def get_influx_data(payload)
        conditions = payload.except(:range, :page, :limit, :order_by, :ordering).map do |k, v|
          case k
          when 'from'
            "created_at >= #{Time.parse(v.to_s).to_i}"
          when 'to'
            "created_at <= #{Time.parse(v.to_s).to_i}"
          when 'user_id', 'id'
            "#{k} = #{v}"
          else
            "#{k} = '#{v}'"
          end
        end
        conditions = conditions.empty? ? '' : " WHERE #{conditions.join(' AND ')}"

        query = "SELECT *
               FROM #{table_name}
               #{conditions}
               GROUP BY id
               ORDER BY #{payload[:order_by]} #{payload[:ordering].upcase}
               LIMIT 1"

        Barong::Influxdb.client.query(query).map { |h| h['values'].first.deep_symbolize_keys! }
      end
    end
  end
end
