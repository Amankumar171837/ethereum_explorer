# frozen_string_literal: true

namespace :activity do
  desc "Update country and country_code for activities based on user_ip"
  task update_country: :environment do
    Activity.where(action: %w[signup login], result: %w[succeed failed]).find_each do |activity|
      location = Barong::GeoIP.info(ip: activity.user_ip, keys: %i[country country_code])
      activity.update_columns(country: location[:country], country_code: location[:country_code])
    end
  end
end
