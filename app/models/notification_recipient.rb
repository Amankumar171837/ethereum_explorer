# frozen_string_literal: true

# Notification Recipient model
class NotificationRecipient < ApplicationRecord

  # == Constants ============================================================

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  serialize :metadata, Hash

  # == Relationships ========================================================

  belongs_to :user
  belongs_to :device
  belongs_to :notification

  # == Validations ==========================================================

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================
end

# == Schema Information
# Schema version: 20240920072708
#
# Table name: notification_recipients
#
#  id              :bigint           not null, primary key
#  notification_id :bigint
#  user_id         :bigint
#  device_id       :bigint
#  status          :string(255)
#  metadata        :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_notification_recipients_on_device_id        (device_id)
#  index_notification_recipients_on_notification_id  (notification_id)
#  index_notification_recipients_on_user_id          (user_id)
#
