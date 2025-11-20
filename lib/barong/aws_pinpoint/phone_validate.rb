# frozen_string_literal: true

module Barong
  module AwsPinpoint
    class PhoneValidate

      Error = Class.new(StandardError)

      class ConnectionError < Error; end
      class InvalidPhoneNumberError < Error; end

      class << self
        def validate(phone_number)
          return unless Barong::App.config.aws_pinpoint_validation

          response = client.phone_number_validate(
            {
              number_validate_request: {
                iso_country_code: parse_country(phone_number),
                phone_number: "+#{phone_number}",
              },
            }
          ).number_validate_response

          unless is_allowed?(response.phone_type)
            Rails.logger.error { "Error: AWS pinpoint response: #{response.to_h}" }
            raise InvalidPhoneNumberError,
                  "Error: AWS Pinpoint phone number #{phone_number}/#{response.phone_type} not allow or not valid"
          end

          response.to_h
        end

        def parse_country(number)
          Phonelib.parse(number).country
        end

        def phone_sanitized(number)
          Phonelib.parse(number).sanitized
        end

        def is_allowed?(phone_type)
          Barong::App.config.aws_pinpoint_allowed_phone_type.any?{ |type| type.casecmp?(phone_type) }
        end

        private

        def client
          @client ||= Barong::AwsPinpoint::Client.new
          @client.aws_client
        end
      end
    end
  end
end
