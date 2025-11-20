# frozen_string_literal: true

# Email type model
class EmailType < ApplicationRecord

  # == Constants ============================================================

  STATUS = %w[active inactive]

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  has_many :email_notifications

  # == Validations ==========================================================

  validates :name, :status, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  # == Scopes ===============================================================

  scope :active, -> { where(status: 'active') }

  # == Callbacks ============================================================

  before_validation do
    self.name = name.downcase
  end

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

end

# == Schema Information
# Schema version: 20240227115123
#
# Table name: email_types
#
#  id          :bigint           not null, primary key
#  name        :string(255)      not null
#  description :string(255)
#  status      :string(255)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_email_types_on_name  (name) UNIQUE
#
