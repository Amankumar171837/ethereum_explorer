# frozen_string_literal: true

require 'sendgrid-ruby'

module SendgridService
  Error = Class.new(StandardError)

  class << self
    include SmsHelper

    def validate_email!(email, source: 'signup')
      return true unless Barong::App.config.enable_sendgrid_email_checker.to_s.to_bool

      response = client.validations.email.post(request_body:
                                                    JSON.parse({
                                                                 email: email,
                                                                 source: source
                                                    }.to_json))
      @response = body_parser(response)
      verdict   = @response.fetch('verdict', '').downcase
      if Barong::App.config.sendgrid_score_enabled.to_s.to_bool
        verdict(verdict) && Barong::App.config.sendgrid_score.to_d <= @response.fetch('score', 0).to_d
      else
        verdict(verdict) && valid?
      end
    rescue StandardError => e
      Rails.logger.error { 'Sendgrid: Connection error' }
      Rails.logger.error { e.message }
      return false
    end

    def verdict(v)
      Barong::App.config.sendgrid_verdict.include?(v)
    end

    def valid?
      @checks = @response.dig('checks')
      return true unless @checks

      valid_domain? && has_known_bounces?
    end

    # Checks if email has the valid domain/syntax or not.
    # Or is it from any disposable email service or not.
    def valid_domain?
      d = @checks.fetch('domain', {})
      d['has_valid_address_syntax'] && d['has_mx_or_a_record'] && !d['is_suspected_disposable_address']
    end

    # Whether email sent to this address from your account has bounced.
    def has_known_bounces?
      !@checks.dig('additional', 'has_known_bounces')
    end

    def verify_user?(user:, code:)
      user.code == code && user.code_expiry_date >= Time.now
    end

    def body_parser(response)
      response = JSON.parse(response.body)
      response.dig('result')
    end

    def client
      SendGrid::API.new(api_key: Barong::App.config.sendgrid_email_api_key).client
    rescue StandardError => e
      Rails.logger.error { 'Sendgrid: Connection error' }
      Rails.logger.error { e.message }
    end
  end
end
