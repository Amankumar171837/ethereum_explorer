# frozen_string_literal: true

module API::V2
  module Public
    class Metrics < Grape::API

      desc 'Get all the continents and it\'s countries'
      params do
        optional :continent,
                 type: String,
                 desc: 'continent.'
        optional :country_code,
                 type: String,
                 desc: 'Country code.'
        optional :city,
                 type: String,
                 desc: 'city .'
      end
      get 'users/metrics' do
        activities = Activity.where(topic: 'account', action: ['signup', 'signup with email'])
                             .where.not(country_code: Barong::App.config.restricted_countries + [nil],
                                        continent: nil, city: nil)

        data = { total_users: activities.count }

        key = if params[:city].present?
                error!({ errors: ['public.metrics.country_required'] }, 422) unless params[:country_code].present?

                'city'
              elsif params[:country_code].present?
                'country'
              elsif params[:continent].present?
                'continent'
              else
                'all'
              end

        data.merge!(Activity.public_send("fetch_#{key}_data", activities, params))

        present data
        status 200
      rescue MetricsHelper::InvalidCountry => e
        Rails.logger.info e.inspect
        error!({ errors: ['public.metrics.invalid_country'] }, 422)
      rescue MetricsHelper::InvalidContinent => e
        Rails.logger.info e.inspect
        error!({ errors: ['public.metrics.invalid_continent'] }, 422)
      end
    end
  end
end
