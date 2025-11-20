# frozen_string_literal: true

require 'yaml'

service_config = YAML.load_file(Rails.root.join('config', 'services.yml')).deep_symbolize_keys!
PlatformSetting::SERVICES_KEYS.push *service_config[:SERVICES_KEYS]
PlatformSetting::SERVICE_TYPES.push *service_config[:SERVICE_TYPES]
services = service_config[:SERVICES].transform_values! do |services|
  services.transform_values! { |config| config[:service].constantize }
end
PlatformSetting::SERVICES.merge!(services)

PlatformSetting::SERVICES_KEYS.freeze
PlatformSetting::SERVICE_TYPES.freeze
PlatformSetting::SERVICES.freeze
