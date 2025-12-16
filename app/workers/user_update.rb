require 'sidekiq'

class UserUpdate

  class WebhookFailed < StandardError; end

  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: Barong::App.config.webhook_retry_count

  def perform(payload)
    payload = JSON.parse(payload)

    user = User.find_by(id: payload['id'])
    return unless user.present?

    client = RegisteredClient.active.find_by(id: payload['client_id'])
    return unless client.present?

    webhook = client.fetch_webhook('user_update')
    return unless webhook&.url&.present?

    body = user.webhook_payload

    response = Barong::ClientWebhook::Api.update_user(webhook.url, body, generate_hmac(client, body))

    if response[:status] == 201
      Activity.create!(
        category: 'user',
        user_id: user.id,
        topic: 'webhook',
        action: 'update_user',
        result: 'succeed',
        data: body.to_json,
        user_ip: '0.0.0.0',
        user_agent: 'sso_service'
      )
    else
      raise WebhookFailed, "Client #{client.id} failed with #{response}"
    end
  rescue => e
    Rails.logger.error("Webhook failed for client=#{client.id}: #{e.message}")
    raise e
  end

  def generate_hmac(client, body)
    digest = OpenSSL::Digest.new('sha256')
    OpenSSL::HMAC.hexdigest(digest, client.secret, body.to_json)
  end
end
