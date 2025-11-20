# frozen_string_literal: true

class CountryService < ApplicationRecord
  # == Constants ============================================================

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  belongs_to :platform_setting

  # == Validations ==========================================================

  validates :country_name, :country_code, :continent, presence: true
  validates :service_type, inclusion: { in: %w[sms email] }
  validates :country_name, uniqueness: { scope: :service_type }

  # == Scopes ===============================================================

  scope :enabled, -> { where(state: 'enabled') }

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def state
    super.try(:inquiry)
  end
end

# == Schema Information
# Schema version: 20230518063543
#
# Table name: country_services
#
#  id                  :bigint           not null, primary key
#  continent           :string(255)
#  country_name        :string(255)      not null
#  country_code        :string(255)      not null
#  state               :string(255)      default("enabled"), not null
#  service_type        :string(255)      not null
#  platform_setting_id :bigint           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_country_services_on_platform_setting_id  (platform_setting_id)
#
