# frozen_string_literal: true

class AuthorizedClient < ApplicationRecord
  # == Constants ============================================================

  STATUS = %w[active inactive]

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  belongs_to :user
  belongs_to :registered_client

  # == Validations ==========================================================

  validates :user_id, uniqueness: { scope: %i[registered_client_id] }
  validates :user_id, :registered_client_id, presence: true
  validates :status, inclusion: { in: STATUS }


  # == Scopes ===============================================================

  scope :active, -> { where(status: 'active') }

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================
end

# == Schema Information
# Schema version: 20251202070947
#
# Table name: authorized_clients
#
#  id                   :bigint           not null, primary key
#  user_id              :bigint
#  registered_client_id :bigint
#  connected_at         :datetime
#  status               :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_authorized_clients_on_registered_client_id  (registered_client_id)
#  index_authorized_clients_on_status                (status)
#  index_authorized_clients_on_user_id               (user_id)
#
