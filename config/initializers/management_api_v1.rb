require 'yaml'
require 'openssl'

(YAML.load_file('config/management_api_v1.yml') || {}).deep_symbolize_keys.tap do |v|
  v.fetch(:keychain).each do |id, key|
    v[:keychain][id][:value] = OpenSSL::PKey.read(Base64.urlsafe_decode64(key.fetch(:value)))
  end

  v.fetch(:actions).each do |name, settings|
    settings[:required_signatures].map!(&:to_sym)
    if settings[:required_signatures].empty?
      raise ArgumentError, "actions.#{name}.required_signatures is empty, " \
                           'however it should contain at least one value (in config/management.yml).'
    end
  end

  Rails.configuration.x.public_send "barong_management_api_v1_configuration=", v
end
