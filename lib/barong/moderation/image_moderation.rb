# frozen_string_literal: true

module Barong
  module Moderation
    class ImageModeration

      Error = Class.new(StandardError)

      class ConnectionError < Error; end

      class << self

        def image(image_path, bucket: Barong::App.config.avatar_storage_bucket_name)
          labels = client.detect_moderation_labels(
            {
              image: {
                s3_object: {
                  bucket: bucket,
                  name: image_path,
                },
              },
              min_confidence: Barong::App.config.avatar_moderation_min_confidence.to_f
            }
          ).moderation_labels

          {
            avg_confidence: avg_confidence(labels),
            reasons: reasons(labels)
          }
        end

        def avg_confidence(labels)
          return 0 if labels.empty?

          labels.pluck(:confidence).sum / labels.count
        end

        def reasons(labels)
          return {} if labels.empty?

          labels.each_with_object([]) do |label, reasons|
            reasons << { confidence: label.confidence,
                         name: label.name,
                         parent_name: label.parent_name }
          end
        end

        private

        def client
          @client ||= Barong::Moderation::Client.new
          @client.aws_client
        end
      end
    end
  end
end
