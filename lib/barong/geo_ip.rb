# frozen_string_literal: true

module Barong
# MaxmindDB reader adapter
  module GeoIP
    class << self
      attr_accessor :lang

      # Usage: city = Barong::GeoIP.get(ip: ip, key: :city)
      def info(ip:, keys: [:country, :country_code, :continent, :city, :coordinates])
        record = reader.get(ip)
        return {} unless record

        keys.each_with_object({}) do |key, result|
          case key.to_sym
          when :country
            result[:country] = record['country']['names'][lang] if record['country'].present?
          when :country_code
            result[:country_code] = record['country']['iso_code'] if record['country'].present?
          when :continent
            result[:continent] = record['continent']['names'][lang] if record['continent'].present?
          when :city
            city_record = read_city.city(ip)
            return unless city_record

             result[:city] = city_record.city.name  if city_record.city.name.present?
          when :coordinates
            city_record = read_city.city(ip)
            return unless city_record

            result[:latitude] = city_record.location.latitude if city_record.location.latitude.present?
            result[:longitude] = city_record.location.longitude if city_record.location.longitude.present?
          end
        end
      rescue StandardError => e
        Rails.logger.debug("Invalid IP Address:  #{e}")
        return nil
      end

      private

      def reader
        @reader ||= MaxMind::DB.new(Barong::App.config.maxminddb_path, mode: MaxMind::DB::MODE_MEMORY)
      end

      def read_city
        @read_city ||= MaxMind::GeoIP2::Reader.new(database: Barong::App.config.maxminddb_city_path.to_s,
                                                   mode: MaxMind::DB::MODE_MEMORY)
      end
    end
  end
end
