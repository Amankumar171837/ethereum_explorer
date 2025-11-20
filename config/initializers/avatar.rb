require 'barong/app'

# Increasing the key spcae limit for now
#::TODO: find a way around.
Rack::Utils.key_space_limit = 123456789

Barong::App.define do |config|
  # Storage configuration for avatar bucket
  config.set(:avatar_storage_provider, 'local')
  config.set(:avatar_storage_bucket_name, 'local')
  config.set(:avatar_storage_access_key, '')
  config.set(:avatar_storage_secret_key, '')
  config.set(:avatar_storage_endpoint, '') # optional (AWS, AliCloud)
  config.set(:avatar_storage_asset_host, '') # optional (For different domain)
  config.set(:avatar_storage_asset_host_enabled, 'false', type: :bool)
  config.set(:avatar_storage_signature_version, '4') # optional (AWS)
  config.set(:avatar_storage_region, '') # optional (AWS, AliCloud)
  config.set(:avatar_storage_pathstyle, 'false', type: :bool) # optional (AWS, AliCloud)
  config.set(:avatar_fog_public, 'true', type: :bool)
  config.set(:avatar_upload_size_min_range, '1', type: :integer) # in megabytes
  config.set(:avatar_upload_size_max_range, '10', type: :integer) # in megabytes
  config.set(:avatar_upload_auth_url_expiration, '1', type: :integer) # in minutes
  config.set(:avatar_upload_extension_whitelist, 'jpg, jpeg, png', type: :array)
  config.set(:avatar_moderation_min_confidence, '50')
  config.set(:avatar_allowed_moderation_min_confidence, '60')
end
