# frozen_string_literal: true

namespace 'update_moderation_for_media' do
  desc 'Moderate user\'s profile image'
  task :image_moderation => :environment do |_|
    ::User.all.each do |u|
      u.medias.each do |media|
        Rails.logger.info { "Started moderation for user profile picture: #{u.uid}" }

        if media.upload.path.nil?
          Rails.logger.warn { 'Skipping media because path is nil' }
          next
        end

        moderation = Barong::Moderation::ImageModeration.image(media.upload.path)
        media.update(moderation_score: moderation[:avg_confidence],
                     moderation_metadata: moderation[:reasons])
      rescue => e
        Rails.logger.error e.message
      end
    end
  end
end
