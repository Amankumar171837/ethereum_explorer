# frozen_string_literal: true

namespace :service_log do
  desc "Update country code for all service logs"
  task update_country_code: :environment do
    puts "Updating country code for service logs"

    ServiceLog.all.each do |log|
      log.update(country_code: Barong::GeoIP.info(ip: log.user_ip, keys: [:country_code])[:country_code])
    end

    puts "Update completed!"
  end
end
