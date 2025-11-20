# frozen_string_literal: true

# FCM service for APIs
class FCMService

  def push_to_device(token:, title:, body:, data: nil)
    payload = build_payload(title, body, data)
    payload[:message][:token] = token
    client.push(payload)
  end

  def push_to_topic(topic:, title:, body:, data: nil)
    payload = build_payload(title, body, data)
    payload[:message][:topic] = topic
    client.push(payload)
  end

  def batch_push(tokens:, title:, body:, data: nil)
    payloads = tokens.map do |token|
      payload = build_payload(title, body, data)
      payload[:message][:token] = token
      payload
    end
    client.batch_push(payloads)
  end

  def subscribe(tokens, topic)
    client.subscribe(topic, tokens)
  end

  def unsubscribe(tokens, topic)
    client.unsubscribe(topic, tokens)
  end

  private

  def build_payload(title, body, data)
    {
      message: {
        notification: {
          title: title,
          body: body
        },
        data: data
      }.compact
    }
  end

  def client
    @client ||= Fcmpush.new(Barong::App.config.fcm_project_id)
  end
end
