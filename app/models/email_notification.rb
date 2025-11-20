# frozen_string_literal: true

# Email Notification model
class EmailNotification < ApplicationRecord

  # == Constants ============================================================

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  belongs_to :user
  belongs_to :email_type

  # == Validations ==========================================================

  validates :user_id, :email, presence: true
  validates :email, uniqueness: { scope: %i[user_id email_type_id] }

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

end

# == Schema Information
# Schema version: 20240227115123
#
# Table name: email_notifications
#
#  id            :bigint           not null, primary key
#  user_id       :bigint           not null
#  email_type_id :bigint           not null
#  email         :string(255)      not null
#  enabled       :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_email_notification_user_email_type    (user_id,email,email_type_id) UNIQUE
#  index_email_notifications_on_email_type_id  (email_type_id)
#  index_email_notifications_on_user_id        (user_id)
#
