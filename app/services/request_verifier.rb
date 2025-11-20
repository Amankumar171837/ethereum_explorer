# frozen_string_literal: true

class RequestVerifier
  def initialize(headers = {}, body = {})
    @token     = headers[:token]
    @signature = headers[:signature]
    @nonce     = (headers[:nonce].to_i * 1000) + 10|| nil
    @body      = body
    @endpoint  = headers[:endpoint] || 'default'
    @verb      = headers[:verb].upcase
    @algorithm = 'SHA256'
  end

  def singup_body
    {
      'channel' => @body[:channel],
      'device_id' => @body[:device_id],
      'device_type' => @body[:device_type],
      'phone_number' => @body[:phone_number],
      'email' => @body[:email],
      'platform' => @body[:platform]
    }.compact
  end

  def resent_body
    {
      'channel' => @body[:channel],
      'device_id' => @body[:device_id],
      'device_type' => @body[:device_type],
      'phone_number' => @body[:phone_number],
      'email' => @body[:email],
      'platform' => @body[:platform]
    }.compact
  end

  def x10_connect_body
    {
      'device_id' => @body[:device_id],
      'device_type' => @body[:device_type],
      'uid' => @body[:uid],
    }.compact
  end

  def default_body
    @body
  end

  def verify_hmac_payload?
    data = "#{@nonce.to_s}.#{method("#{@endpoint}_body").call}.#{@verb}.#{@token}"
    true_signature = OpenSSL::HMAC.hexdigest(@algorithm, auth_token, data)
    true_signature == @signature
  end

  private

  def auth_token
    if @endpoint == 'x10_connect'
      Barong::App.config.app_auth_x10_token
    else
      Barong::App.config.app_auth_token
    end
  end
end
