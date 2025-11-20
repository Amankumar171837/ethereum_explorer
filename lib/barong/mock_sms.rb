# frozen_string_literal: true

module Barong
  # empty sms service
  class MockSMS
    cattr_accessor :messages
    def initialize(_account_sid, _auth_token) end

    def messages
      self
    end

    def create(params)
      OpenStruct.new(params)
    end
  end
end
