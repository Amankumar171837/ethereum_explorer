# frozen_string_literal: true

# Service Logs model
class ServiceLog < ApplicationRecord
  include InfluxHelper

  # == Constants ============================================================

  STATUS = { failed: %w[failed Failed not_delivered undeliverable],
             success: %w[success delivered Delivered],
             in_progress: %w[pending submitted accepted approved in_transit],
             suspicious: %w[unknown Unknown expired_auth spam_detected expired rate_limited rejected no_attempt] }

  STATUS_LIST = {1 => 'delivered', 2 => 'unavailable', 3 => 'not_delivered'}

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  belongs_to :user
  belongs_to :platform_setting

  # == Validations ==========================================================

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  before_validation on: :create do
    location = Barong::GeoIP.info(ip: user_ip, keys: %i[country country_code])
    self.service_name = platform_setting.service_name
    self.user_country ||= location[:country]
    self.country_code ||= location[:country_code]
  end

  after_commit :create_record_in_influx_db, on: %i[create update]

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def influx_data
    data = { values: { user_id: user_id,
                       user_email: user.email,
                       service_name: service_name,
                       service_type: service_type,
                       platform_setting_id: platform_setting_id,
                       topic: topic,
                       result: result,
                       user_ip: user_ip,
                       user_country: user_country,
                       metadata: metadata.to_json,
                       created_at: created_at.to_i}.compact,
             tags: { user_id: user_id }.compact,
             timestamp: created_at.to_i}
    data[:values][:id] = id if id.present?
    data[:tags][:id] = id if id.present?
    data
  end
end

# == Schema Information
# Schema version: 20241119110337
#
# Table name: service_logs
#
#  id                  :bigint           not null, primary key
#  service_name        :string(255)      not null
#  service_type        :string(255)      not null
#  user_id             :bigint           not null
#  platform_setting_id :bigint           not null
#  topic               :string(255)      not null
#  result              :string(255)      not null
#  user_ip             :string(255)      not null
#  user_country        :string(255)
#  country_code        :string(255)
#  phone_number        :string(255)
#  sms_id              :string(255)
#  metadata            :json
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_service_logs_on_platform_setting_id  (platform_setting_id)
#  index_service_logs_on_user_id              (user_id)
#
