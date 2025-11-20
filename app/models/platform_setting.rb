# frozen_string_literal: true

# PlatformSetting model
class PlatformSetting < ApplicationRecord

  class ServiceNotFound < StandardError; end

  # == Constants ============================================================

  SERVICES      = {}
  SERVICES_KEYS = []
  SERVICE_TYPES = []

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  has_many :service_logs
  has_many :country_services

  # == Validations ==========================================================

  before_validation :validate_sms_service, on: :create

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  class << self
    def verify_service(number, type = 'sms')
      cs = CountryService.enabled.where("(country_code = ? OR country_name = 'all') and service_type = ?",
                                        Phonelib.parse(number).country, type)

      raise ServiceNotFound, 'Country service not found.' if cs.empty?

      cs = cs.count == 1 ? cs.first : cs.find_by("country_code != 'all' ")

      get_service(type, cs.platform_setting.service_key)
    end

    def service(key = 'sms', number)
      cs = CountryService.where("(country_code = ? OR country_name = 'all') and service_type = ?",
                                Phonelib.parse(number).country, key)

      raise ServiceNotFound, 'Service not found.' if cs.empty?

      cs = cs.count == 1 ? cs.first : cs.find_by("country_code != 'all' ")

      raise ServiceNotFound, 'Service is disabled.' if cs.state.disabled?

      ps = cs.platform_setting
      raise ServiceNotFound, 'Platform setting not found or disabled.' unless ps && ps.state.enabled?

      ps
    end

    def get_service(type, service_key)
      SERVICES.dig(type.to_sym, service_key.to_sym)
    end

    def sms_service_client(number)
      service = service(number)
      case service.service_key
      when 'twilio_sms', 'twilio_verify'
        sid = Barong::App.config.twilio_account_sid
        token = Barong::App.config.twilio_auth_token
        raise 'Invalid twilio config' if sid.to_s.empty? || token.to_s.empty?

        Twilio::REST::Client.new(sid, token)
      when 'aws_sns'
        region = Barong::App.config.sms_aws_region
        access_key_id = Barong::App.config.sms_aws_access_key_id
        secret_access_key = Barong::App.config.sms_aws_secret_access_key
        raise 'Invalid aws config' if access_key_id.to_s.empty? || secret_access_key.to_s.empty?

        Aws::SNS::Client.new(access_key_id: access_key_id, secret_access_key: secret_access_key,region: region)
      when 'mock'
        Barong::MockSMS.new('', '')
      when 'bulkgate'
        Barong::Bulkgate::BulkgateVerification
      when 'mobivate'
        Barong::Mobivate::MobivateVerification
      when 'smsala'
        Barong::Smsala::SmsalaApi
      when 'ding'
        Barong::Ding::DingApi
      else
        raise "Unknown client service #{service.service_key}"
      end
    end
  end

  # == Instance Methods =====================================================

  def validate_sms_service
    unless service_key.in?(SERVICES_KEYS)
      errors.add(:service_key, 'is invalid')
    end
  end

  def state
    super.try(:inquiry)
  end
end

# == Schema Information
# Schema version: 20230810125557
#
# Table name: platform_settings
#
#  id           :bigint           not null, primary key
#  service_type :string(255)      not null
#  service_name :string(255)      not null
#  state        :string(255)      default("enabled"), not null
#  service_key  :string(255)      not null
#  metadata     :json
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
