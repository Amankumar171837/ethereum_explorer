# frozen_string_literal: true

# Media  model
class Media < ApplicationRecord
  acts_as_redpanda_eventable prefix: 'media', on: %i[create update]

  # == Constants ============================================================

  STATES = %w[active inactive].freeze
  TYPES = %w[default wonka token].freeze

  # == Attributes ===========================================================

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  # == Extensions ===========================================================

  mount_uploader :upload, Barong::App.config.avatar_uploader
  serialize :moderation_metadata, JSON

  # == Relationships ========================================================

  belongs_to :user

  # == Validations ==========================================================

  validates :type, presence: true, inclusion: { in: TYPES }

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  before_validation do
    self.state ||= 'active'
    self.type  ||= 'default'
  end

  after_commit :update_medias, on: %i[create update]

  # == Class Methods ========================================================

  class << self
    def generate_file(params)
      img = File.new("profile_pictures/#{generate_name(4)}.jpeg", 'wb')
      img.write(Base64.decode64(params[:upload]['data:image/png;base64,'.length..-1]))
      img
    end

    def generate_name(times, name = '')
      return name[0..-2] if (0..1).include?(times)

      name += (Time.now.to_i * rand(100)).to_s + '_'

      generate_name(times - 1, name)
    end
  end

  self.inheritance_column = nil

  # == Instance Methods =====================================================

  def create_versions(params)
    self.crop_x =  params[:x]
    self.crop_y =  params[:y]
    self.crop_w =  params[:w]
    self.crop_h =  params[:h]
    upload.recreate_versions!
  end

  def as_json_for_redpanda_api
    user.as_json_for_redpanda_api
        .merge(profile_pictures: moderated_media,
               profile_state: state,
               moderation_score: moderation_score,
               type: type,
               image_urls: image_urls)
  end

  def moderated_media
    return if moderation_score.nil? ||
      moderation_score.to_f >= Barong::App.config.avatar_allowed_moderation_min_confidence.to_f

    upload
  end

  def update_medias
    if state == 'active'
      user.medias.find_by('id != ? && state = ?', id, 'active')&.update(state: 'inactive')
    end
  end

  # ::TODO:: Remove me, once this is fixed by mobile team. And also remove same method
  # from *_redpanda_api_*.
  def redpanda_event_name(tokens)
    'model.media.created'
  end

  def skip_redpanda_event?
    state == 'inactive'
  end
end

# == Schema Information
# Schema version: 20240227115123
#
# Table name: media
#
#  id                  :bigint           not null, primary key
#  user_id             :bigint           unsigned, not null
#  upload              :string(255)
#  moderation_score    :string(255)
#  moderation_metadata :text(65535)
#  image_urls          :json
#  type                :string(255)
#  state               :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
