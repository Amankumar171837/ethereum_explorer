# frozen_string_literal: true

class RegisteredClient < ApplicationRecord

  include Vault::EncryptedModel

  # == Constants ============================================================

  STATES = %w[active inactive]

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  vault_lazy_decrypt!
  vault_attribute :secret

  serialize :scope, Array

  # == Relationships ========================================================

  # == Validations ==========================================================

  validates :name, :redirect_url, :secret, presence: true
  validates :kid, presence: true, uniqueness: true
  validates :state, inclusion: { in: STATES }

  before_validation :assign_credentials!
  before_validation do
    self.name = name.downcase
  end

  # == Scopes ===============================================================

  scope :active, -> { where(state: 'active') }

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def assign_credentials!
    return unless kid.blank?

    self.kid = "#{Barong::App.config.client_id_prefix}" + SecureRandom.hex(16)
    self.secret = SecureRandom.hex(32)
  end
end

# == Schema Information
# Schema version: 20251127150128
#
# Table name: registered_clients
#
#  id               :bigint           not null, primary key
#  name             :string(255)      not null
#  kid              :string(255)      not null
#  secret_encrypted :string(1024)
#  scope            :string(255)
#  redirect_url     :string(255)      not null
#  state            :string(255)      default("active"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_registered_clients_on_kid  (kid) UNIQUE
#
