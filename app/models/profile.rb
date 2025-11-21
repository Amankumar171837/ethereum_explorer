# frozen_string_literal: true

# Profile model
class Profile < ApplicationRecord
  include Encryptable

  # acts_as_eventable prefix: 'profile', on: %i[create update]

  belongs_to :user

  enum state: { drafted: 0, submitted: 1, verified: 3, rejected: 4, social: 5 }

  EDITABLE_PARAMS = { drafted: %w[first_name last_name dob address postcode city country metadata]}
  OPTIONAL_PARAMS = %w[first_name middle_name last_name dob address postcode city country].freeze

  attr_encrypted :first_name
  attr_encrypted :last_name
  attr_encrypted :middle_name
  attr_encrypted :dob
  attr_encrypted :address

  validates :first_name, length: 1..255,
                         format: {
                           with: /\A[[:word:]\s\-']+\z/,
                           message: 'only allows letters, digits "-", "\'", and space'
                         },
                         if: proc { |a| a.first_name.present? }
  validates :middle_name, length: 1..255,
                          format: {
                            with: /\A[[:word:]\s\-']+\z/,
                            message: 'only allows letters, digits "-", "\'", and space'
                          },
                          if: proc { |a| a.middle_name.present? }
  validates :last_name, length: 1..255,
                        format: {
                          with: /\A[[:word:]\s\-']+\z/,
                          message: 'only allows letters, digits "-", "\'", and space'
                        },
                        if: proc { |a| a.last_name.present? }
  validates :city, length: 1..255,
                   format: {
                     with: /\A[[:word:]\s\-\–\.~']+\z/,
                     message: 'only allows letters, digits "-", "–", "\'", ".", "~" and space'
                   },
                   if: proc { |a| a.city.present? }
  validate :validate_country_format, if: ->(p) { p.country.present? }
  validates :postcode, length: 2..255,
                       format: {
                         with: /\A[[:word:]\s\-]+\z/,
                         message: 'only allows letters, digits, "-" and space'
                       },
                       if: proc { |a| a.postcode.present? }

  validates :address, length: 1..255,
                      format: {
                        with: /\A[[:word:]\s\-\–\,\.~;\/:\#"\\&\')\(]+\z/,
                        message: 'only allows letters, digits "-", "–", "\'", ".", ",", "#", ":", ";", "&" and space'
                      },
                      if: proc { |a| a.address.present? }
  validates :metadata, data_is_json: true
  validate :profile_state!, on: :create
  validate :dob_not_in_the_future

  scope :kept, -> { joins(:user).where(users: { discarded_at: nil }) }

  before_validation do
    squish_spaces
  end

  def full_name
    return "#{first_name} #{middle_name} #{last_name}" if middle_name

    "#{first_name} #{last_name}"
  end

  def sub_masked_first_name
    first_name.sub(/(?<=\A.{1})(.*)/) { |match| '*' * match.length } if first_name
  end

  def sub_masked_last_name
    last_name.sub(/(?<=\A.{1})(.*)/) { |match| '*' * match.length } if last_name
  end

  def sub_masked_middle_name
    middle_name.sub(/(?<=\A.{1})(.*)/) { |match| '*' * match.length } if middle_name
  end

  def sub_masked_dob
    dob.to_s.sub(/(?<=\A.{8})(.*)/) { |match| '*' * match.length } if dob
  end

  def as_json_for_event_api
    {
      user: user.as_json_for_event_api,
      first_name: first_name,
      middle_name: middle_name,
      last_name: last_name,
      dob: format_iso8601_time(dob),
      address: address,
      postcode: postcode,
      city: city,
      country: country,
      metadata: metadata,
      created_at: format_iso8601_time(created_at),
      updated_at: format_iso8601_time(updated_at)
    }
  end

  private

  def validate_country_format
    return if ISO3166::Country.find_country_by_alpha2(country) ||
              ISO3166::Country.find_country_by_alpha3(country)

    errors.add(:country, 'must have alpha2 or alpha3 format')
  end

  def squish_spaces
    self.first_name = first_name&.squish
    self.middle_name = middle_name&.squish if middle_name
    self.last_name = last_name&.squish
    self.city = city&.squish
    self.postcode = postcode&.squish
  end

  def profile_state!
    # No limits for storing verified and rejected profiles
    return if state.in?(%w[verified rejected social])

    # This check is actual for profile states [drafted submitted]
    # User cant have more than one DRAFTED or SUMBITTED profile at one time
    user_profiles_states = self.user.profiles.pluck(:state)
    if user_profiles_states.include?('drafted') ||  user_profiles_states.include?('submitted')
      errors.add(:state, :exists, message: 'already exists')
    end
  end

  def dob_not_in_the_future
    return if dob.nil?

    self.dob = dob.to_date
    return errors.add(:dob, :invalid_format, message: 'invalid date format') unless dob.is_a?(Date)
    return errors.add(:dob, :invalid, message: 'cant be in future') if dob > Date.current
  end
end

# == Schema Information
# Schema version: 20240920072708
#
# Table name: profiles
#
#  id                    :bigint           not null, primary key
#  user_id               :bigint
#  author                :string(255)
#  first_name_encrypted  :string(1024)
#  last_name_encrypted   :string(1024)
#  middle_name_encrypted :string(1024)
#  dob_encrypted         :string(255)
#  address_encrypted     :string(1024)
#  postcode              :string(255)
#  city                  :string(255)
#  country               :string(255)
#  state                 :integer          default("drafted"), unsigned
#  metadata              :text(65535)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_profiles_on_user_id  (user_id)
#
