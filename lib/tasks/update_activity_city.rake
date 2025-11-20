# frozen_string_literal: true

namespace :activity do
  desc "Update city based on user_ip"
  task update_city: :environment do
    Activity.where(action: ['signup', 'signup with email']).find_each do |activity|
      data = Barong::GeoIP.info(ip: activity.user_ip)
      next unless data.present?

      data.merge!(coordinates: { latitude: data[:latitude], longitude: data[:longitude] }).except!(:latitude, :longitude)
      activity.update_columns(data)
    end
  end
end
