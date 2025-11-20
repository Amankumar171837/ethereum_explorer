# frozen_string_literal: true

class SmsSenderConfig < ApplicationRecord

  # == Constants ============================================================

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  enum status: { active: 1, inactive: 0 }

  # == Relationships ========================================================

  belongs_to :platform_setting

  # == Validations ==========================================================

  before_validation do
    self.country = ISO3166::Country.find_country_by_alpha2(country_code)&.name
  end

  # == Scopes ===============================================================

  scope :active, -> { where(status: 'active') }

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

end

# == Schema Information
# Schema version: 20230810125557
#
# Table name: sms_sender_configs
#
#  id                  :bigint           not null, primary key
#  platform_setting_id :bigint
#  country             :string(255)
#  country_code        :string(255)
#  sender              :string(255)
#  status              :integer
#  metadata            :text(65535)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_sms_sender_configs_on_platform_setting_id  (platform_setting_id)
#
