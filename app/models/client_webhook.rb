# frozen_string_literal: true

class ClientWebhook < ApplicationRecord
  # == Constants ============================================================

  STATUS = %w[active inactive]
  EVENTS = %w[user_update]

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  belongs_to :registered_client

  # == Validations ==========================================================

  validates :url, presence: true
  validates :event, uniqueness: { scope: %i[registered_client_id] }
  validates :status, presence: true, inclusion: { in: STATUS }
  validates :event, presence: true, inclusion: { in: EVENTS }

  # == Scopes ===============================================================

  scope :active, -> { where(status: 'active') }

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================
end

# == Schema Information
# Schema version: 20251216075339
#
# Table name: client_webhooks
#
#  id                   :bigint           not null, primary key
#  registered_client_id :bigint
#  url                  :string(255)      not null
#  event                :string(255)      not null
#  status               :string(255)      default("active"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_client_webhooks_on_event_and_registered_client_id  (event,registered_client_id) UNIQUE
#  index_client_webhooks_on_registered_client_id            (registered_client_id)
#
