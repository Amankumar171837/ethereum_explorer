# frozen_string_literal: true

# Notification model
class Notification < ApplicationRecord

  # == Constants ============================================================

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  serialize :metadata, Hash

  # == Relationships ========================================================

  has_many :notification_recipients

  # == Validations ==========================================================

  validates :body, :title, presence: true

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================
end

# == Schema Information
# Schema version: 20240920072708
#
# Table name: notifications
#
#  id         :bigint           not null, primary key
#  title      :string(255)
#  body       :text(65535)
#  metadata   :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
