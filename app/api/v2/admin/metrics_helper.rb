# frozen_string_literal: true

module API
  module V2
    module Admin
      module MetricsHelper
        extend ::Grape::API::Helpers

        def format_result(period, *args)
          send("#{period}", *args)
        end

        def daily(*args)
          result = (0..23).each_with_object({}) do |i, h|
            hour = i.to_s.rjust(2, '0')

            value = args.map do |arg|
              arg[hour].nil? ? 0 : arg[hour]
            end
            h[hour] = value
          end

          result = result.map { |key, value| [key, *value] }
          result.rotate!(-(24 - Time.now.in_time_zone(params[:timezone]).hour))
        end

        def weekly(*args)
          days = %w[Sun Mon Tue Wed Thu Fri Sat]

          result = days.each_with_object({}) do |day, h|
            value = args.map do |arg|
              arg[day].nil? ? 0 : arg[day]
            end
            h[day] = value
          end

          result = result.map { |key, value| [key, *value] }
          result.rotate(1 + Time.now.in_time_zone(params[:timezone]).wday)
        end

        def monthly(*args)
          from_date = params[:from].to_date
          to_date = params[:to].to_date

          (from_date..to_date).map do |date|
            value = args.map do |arg|
              arg[date.strftime('%d %b')].nil? ? 0 : arg[date.strftime('%d %b')]
            end
            [date.strftime('%-d %b'), *value]
          end
        end

        def yearly(*args)
          months = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]

          result = months.each_with_object({}) do |mon, h|
            value = args.map do |arg|
              arg[mon].nil? ? 0 : arg[mon]
            end
            h[mon] = value
          end
          result = result.map { |key, value| [key, *value] }

          start_month = DateTime.parse("#{params[:from]}").strftime("%b")
          end_month = DateTime.parse("#{params[:to]}").strftime("%b")

          start_index = result.index { |month_data| month_data[0] == start_month }
          end_index = result.index { |month_data| month_data[0] == end_month }

          data = []
          if start_index && end_index
            data = if start_index <= end_index
                     result[start_index..end_index]
                   else
                     result[start_index..-1] + result[0..end_index]
                   end
          end

          data
        end

        def all(*args)
          default = Time.now.year if args.all?(&:empty?)

          min = default || args.flat_map(&:keys).min.to_i
          max = default || args.flat_map(&:keys).max.to_i

          result = (min..max).each_with_object({}) do |i, h|
            value = args.map do |arg|
              arg[i.to_s].nil? ? 0 : arg[i.to_s]
            end
            h[i.to_s] = value
          end

          result.map { |key, value| [key, *value] }
        end

        def fetch_metrics_data(params, data_method)
          if params[:from] || params[:to]
            params[:to] = Time.now.in_time_zone(params[:timezone]) if params[:to].nil?
            params[:from] = DateTime.parse('1947-02-02 00:00:00') if params[:from].nil?

            date_diff = (params[:to].to_date - params[:from].to_date).to_i
            customized_tp = params[:from].present?

            params[:period] = case date_diff
                              when 0...31
                                'monthly'
                              when 31...365
                                'yearly'
                              else
                                'all'
                              end
          end

          params[:from], params[:to], format = get_timeperiod(params)

          if customized_tp
            send(data_method, format)
          else
            expiry_time = Time.now.in_time_zone(params[:timezone]).end_of_hour - Time.now.in_time_zone(params[:timezone])
            cache_key = :"#{data_method}_#{params[:country_code]}_#{params[:period]}_#{params[:timezone]}"

            Rails.cache.fetch(cache_key, expires_in: expiry_time.to_i) do
              send(data_method, format)
            end
          end
        end

        def get_timeperiod(params)
          from = params[:from]&.to_date&.in_time_zone(params[:timezone])&.beginning_of_day
          to = params[:to]&.to_date&.in_time_zone(params[:timezone])&.end_of_day
          now = Time.now.in_time_zone(params[:timezone])

          case params[:period]
          when 'daily'
            [24.hour.ago.in_time_zone(params[:timezone]).beginning_of_hour,
             now.beginning_of_hour - 1, '%H']
          when 'weekly'
            [6.days.ago.in_time_zone(params[:timezone]).beginning_of_day,
             now.end_of_day, '%a']
          when 'monthly'
            [from || 1.month.ago.in_time_zone(params[:timezone]).beginning_of_day,
             to || now.end_of_day, '%d %b']
          when 'yearly'
            [from || (1.year.ago.in_time_zone(params[:timezone]).end_of_month + 1.day).beginning_of_day,
             to || now, '%b']
          when 'all'
            [from, to, '%Y']
          end
        end
      end
    end
  end
end
