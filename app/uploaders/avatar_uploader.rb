# frozen_string_literal: true

# It's for upload document for Document model
class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  if Rails.env.production?
    storage :fog
  else
    storage :file
  end

  # define some uploader specific configurations in the initializer
  # to override the global configuration
  def initialize(*)
    super

    self.fog_credentials = {
      provider: 'AWS',
      aws_signature_version: Barong::App.config.avatar_storage_signature_version,
      aws_access_key_id: Barong::App.config.avatar_storage_access_key,
      aws_secret_access_key: Barong::App.config.avatar_storage_secret_key,
      region: Barong::App.config.avatar_storage_region,
      endpoint: Barong::App.config.avatar_storage_endpoint,
      path_style: Barong::App.config.avatar_storage_pathstyle
    }
    if Barong::App.config.avatar_storage_asset_host_enabled
      self.asset_host = Barong::App.config.avatar_storage_asset_host
    end
    self.fog_directory = Barong::App.config.avatar_storage_bucket_name
  end

  (Barong::App.config.image_versions['versions'] || []).each do |key, value|
    version :"#{key}" do
      process resize_to_fit: [value['h'], value['w']]
      process :crop
      process :round_corners => [value['r']] if key == 'dpr'
    end
  end

  def crop
    if model.crop_x.present?
      manipulate! do |img|
        x = model.crop_x.to_i
        y = model.crop_y.to_i
        w = model.crop_w.to_i
        h = model.crop_h.to_i
        img.crop([[w, h].join('x'), [x, y].join('+')].join('+'))
      end
    end
  end

  def round_corners(r)
    manipulate! do |img|

      mask = ::MiniMagick::Image.open img.path
      mask.format 'png'
      mask.combine_options do |m|
        m.alpha 'transparent'
        m.draw "roundrectangle 0, 0, #{img[:width]}, #{img[:height]}, #{r}, #{r}"
      end

      img.composite(mask, 'png') do |i|
        i.alpha 'set'
        i.compose 'DstIn'
      end
    end
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "avatar/#{(model.user_id * 3).to_s(16).downcase}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    Barong::App.config.avatar_upload_extension_whitelist
  end

  def size_range
    # default is 1..10.megabytes
    Barong::App.config.avatar_upload_size_min_range..Barong::App.config.avatar_upload_size_max_range.megabytes
  end

  # Override default 'publicly visible' policy of fog
  def fog_public
    # (default is true, which is not recommended for KYC documents or any user info
    Barong::App.config.avatar_fog_public
  end

  # Set the expire time of authentification signature
  def fog_authenticated_url_expiration
    Barong::App.config.avatar_upload_auth_url_expiration.minutes # (default is 1.minute)
  end
end
