# encoding: UTF-8
# frozen_string_literal: true

module MetricsHelper
  extend ActiveSupport::Concern

  Error = Class.new(StandardError)

  class InvalidContinent < Error; end

  class InvalidCountry < Error; end

  class_methods do
    def get_continents
      %w[Asia North\ America Africa Europe South\ America Antarctica Oceania]
    end

    def fetch_all_data(_, _)
      Rails.cache.fetch('all_metrics', expires_in: 900) do
        {
          continents: all_data_query.group_by { |entry| entry[0] }.transform_values do |continent_data|
            {
              total_users: continent_data.sum { |entry| entry[3].to_i }
            }.merge(continent_data.group_by { |entry| entry[1] }.transform_values do |country_data|
              {
                total_users: country_data.sum { |entry| entry[3].to_i },
                cities: country_data.map do |entry|
                  {
                    name: entry[2],
                    total_users: entry[3].to_i,
                    coordinates: JSON.parse(entry[4])
                  }
                end
              }
            end)
          end
        }
      end
    end

    def fetch_city_data(activities, params)
      continent = validate_country!(params)

      activities_cont = activities.where(continent: continent)
      activities_country = activities_cont.where(country_code: params[:country_code])

      cities = city_query(activities_country, params[:city])

      {
        continent => {
          total_users: activities_cont.count,
          params[:country_code].upcase => {
            total_users: activities_country.count,
            cities: cities
          }
        }
      }
    end

    def fetch_country_data(activities, params)
      continent = validate_country!(params)

      activities_cont = activities.where(continent: continent)
      activities_country = activities_cont.where(country_code: params[:country_code])

      cities = city_query(activities_country)

      {
        continent => {
          total_users: activities_cont.count,
          params[:country_code].upcase => {
            total_users: activities_country.count,
            cities: cities
          }
        }
      }
    end

    def fetch_continent_data(activities, params)
      raise InvalidContinent, "Invalid continent" unless get_continents.include?(params[:continent])

      activities_cont = activities.where(continent: params[:continent])
      countries = activities_cont.group(:country_code).distinct.count(:user_id)

      {
        params[:continent] => {
          total_users: activities_cont.count,
          countries: countries
        }
      }
    end

    def city_query(scope, specific_city = nil)
      query = scope.select(
        'city AS name',
        'COUNT(DISTINCT user_id) AS total_users',
        'MIN(coordinates) AS coordinates'
      ).where.not(city: nil)

      query = query.where(city: specific_city) if specific_city
      query.group(:city).map { |city| city.attributes.except('id') }.reject { |c| c['name'].nil? }
    end

    def all_data_query
      sql = <<-SQL
          SELECT
            continent,
            country_code,
            city,
            COUNT(DISTINCT user_id) AS total_count,
            JSON_OBJECT(
              'latitude', MIN(JSON_EXTRACT(coordinates, '$.latitude')),
              'longitude', MIN(JSON_EXTRACT(coordinates, '$.longitude'))
            ) AS coordinates
          FROM activities
          WHERE continent IS NOT NULL AND
                country_code IS NOT NULL AND
                city IS NOT NULL AND
                topic = 'account'AND
                action IN ('signup', 'signup with email') AND
                country_code NOT IN (#{Barong::App.config.restricted_countries.map { |code| "'#{code}'" }.join(', ')})
          GROUP BY continent, country_code, city
      SQL

      ActiveRecord::Base.connection.execute(sql).to_a
    end

    def validate_country!(params)
      continent = ISO3166::Country[params[:country_code]]&.continent
      raise InvalidCountry, "Invalid country" unless continent

      continent
    end
  end
end
