# frozen_string_literal: true

namespace 'generate_missing_labels' do
  desc 'Generate missing labels for users'
  task :generate => :environment do |_|
    ::User.all.each do |u|
      # Skip user if system generated.
      next if u.filter_email == ''

      u.reload

      unless u.platform == 'app'
        ActiveRecord::Base.transaction do
          label = u.labels.find_or_initialize_by(key: 'login_email', scope: 'private')
          label.update(value: 'verified')
          label = u.labels.find_or_initialize_by(key: 'login_phone', scope: 'private')
          label.update(value: 'pending') if label.value != 'verified'
          if u.labels.find_by(key: 'phone', value: 'verified', scope: 'private') && u.phone_number.to_s != ''
            label.update(value: 'verified')
          end
        end
      end
    end
  end
end
