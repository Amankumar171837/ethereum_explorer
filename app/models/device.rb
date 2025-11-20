# frozen_string_literal: true

# Device model
class Device < ApplicationRecord

  # == Constants ============================================================

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  belongs_to :user
  has_many :notifications

  # == Validations ==========================================================

  validates :user_id, :device_type, :device_id, presence: true
  validates :device_id, uniqueness: { scope: %i[user_id device_type] }

  # == Scopes ===============================================================

  scope :active, -> { where(active: true) }

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================
end

# == Schema Information
# Schema version: 20240712094827
#
# Table name: devices
#
#  id           :bigint           not null, primary key
#  user_id      :bigint
#  device_id    :string(255)      not null
#  device_type  :string(255)      not null
#  device_token :string(255)
#  active       :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_devices_on_user_id                                (user_id)
#  index_devices_on_user_id_and_device_id_and_device_type  (user_id,device_id,device_type) UNIQUE
#
