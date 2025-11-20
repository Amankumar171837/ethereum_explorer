# frozen_string_literal: true

module API
  module V2
    module Admin
      # Metrics functionality
      class Metrics < Grape::API

        helpers MetricsHelper

        helpers do
          def permitted_search_params(params)
            params.slice(:from, :to, :topic, :action, :result, :country_code).merge(with_user: false)
          end

          def searchable_params(params)
            params.slice(:from, :to, :result, :country_code).merge(with_user: false)
          end

          def count_by_timeframe(records, timezone, format)
            records.group("DATE_FORMAT(CONVERT_TZ(created_at, '+00:00', '#{timezone}'), '#{format}')").size
          end

          def activity(format)
            signup = API::V2::Queries::ActivityFilter.new(Activity.all).call(
              permitted_search_params(params.merge(topic: 'account', action: 'signup, signup with email', result: 'succeed'))
            )
            signup_with_email = API::V2::Queries::ActivityFilter.new(signup).call(
              permitted_search_params(params.merge(topic: 'account', action: 'signup with email', result: 'succeed'))
            )
            signup_with_phone = API::V2::Queries::ActivityFilter.new(signup).call(
              permitted_search_params(params.merge(topic: 'account', action: 'signup', result: 'succeed'))
            )
            successful_login = API::V2::Queries::ActivityFilter.new(Activity.all).call(
              permitted_search_params(params.merge(topic: 'session', action: 'login', result: 'succeed'))
            )
            failed_login = API::V2::Queries::ActivityFilter.new(Activity.all).call(
              permitted_search_params(params.merge(topic: 'session', action: 'login', result: 'failed'))
            )

            timezone = ActiveSupport::TimeZone[params[:timezone]].formatted_offset

            result = [signup, signup_with_email, signup_with_phone, successful_login, failed_login]
                       .map { |data| count_by_timeframe(data, timezone, format)}

            result = format_result(params[:period], *result)
            result.insert(0, ['x', 'Signups', 'Signups With Email', 'Signups With Phone', 'Successful Logins', 'Failed Logins'])
            result
          end

          def service_logs(format)
            results = %i[success failed in_progress suspicious].map do |state|
              API::V2::Queries::ServiceLogFilter.new(ServiceLog.all).call(
                searchable_params(params.merge(result: ServiceLog::STATUS[state]))
              )
            end

            timezone = ActiveSupport::TimeZone[params[:timezone]].formatted_offset
            result = results.map { |data| count_by_timeframe(data, timezone, format) }

            result = format_result(params[:period], *result)
            result.insert(0, ['x', 'Success', 'Failed', 'In Progress', 'Suspicious'])
            result
          end
        end

        resource :metrics do
          desc 'Returns main statistic in the given time period',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ]
          params do
            optional :period,
                     type: String,
                     values: { value: -> (p){ %w[daily weekly monthly yearly all].include?(p) },
                               message: 'admin.metric.invalid_period' },
                     default: 'all',
                     desc: 'Time period for calculating total activity count'
            optional :country_code,
                     type: String,
                     desc: 'Country code'
            optional :from,
                     type: DateTime,
                     coerce_with: ->(v) { DateTime.parse(v.to_s) },
                     desc: 'Start date'
            optional :to,
                     type: DateTime,
                     coerce_with: ->(v) { DateTime.parse(v.to_s) },
                     desc: 'End date'
            optional :timezone,
                     type: String,
                     default: 'UTC',
                     desc: 'Timezone name'
          end
          get do
            admin_authorize! :read, User

            result = fetch_metrics_data(params, :activity)
            present result
          end

          desc 'Returns service logs in the given time period',
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ]
          params do
            optional :period,
                     type: String,
                     values: { value: -> (p){ %w[daily weekly monthly yearly all].include?(p) },
                               message: 'admin.metric.invalid_period' },
                     default: 'all',
                     desc: 'Time period for calculating total service log count'
            optional :country_code,
                     type: String,
                     desc: 'Country code'
            optional :from,
                     type: DateTime,
                     coerce_with: ->(v) { DateTime.parse(v.to_s) },
                     desc: 'Start date'
            optional :to,
                     type: DateTime,
                     coerce_with: ->(v) { DateTime.parse(v.to_s) },
                     desc: 'End date'
            optional :timezone,
                     type: String,
                     default: 'UTC',
                     desc: 'Timezone name'
          end
          get '/service-logs' do
            admin_authorize! :read, User

            result = fetch_metrics_data(params, :service_logs)
            present result
          end

          desc 'Returns main statistic in the given time period',
            security: [{ "BearerToken": [] }],
            failure: [
              { code: 401, message: 'Invalid bearer token' }
            ]
          get 'statistic' do
            admin_authorize! :read, User

            result = {}

            signup = API::V2::Queries::ActivityFilter.new(Activity.all).call(
              permitted_search_params(params.merge(topic: 'account', action: 'signup',
                                                   result: 'succeed', from: Time.zone.today))
            )
            successful_login = API::V2::Queries::ActivityFilter.new(Activity.all).call(
              permitted_search_params(params.merge(topic: 'session', action: 'login',
                                                   result: 'succeed', from: Time.zone.today))
            )
            failed_login = API::V2::Queries::ActivityFilter.new(Activity.all).call(
              permitted_search_params(params.merge(topic: 'session', action: 'login',
                                                   result: 'failed', from: Time.zone.today))
            )

            result[:signups] = signup.group('date(created_at)').size
            result[:successful_logins] = successful_login.group('date(created_at)').size
            result[:failed_logins] = failed_login.group('date(created_at)').size

            result[:pending_applications] = Label.where({ key: 'document', value: 'pending',
                                                          scope: 'private' }).count

            present result
          end
        end
      end
    end
  end
end
