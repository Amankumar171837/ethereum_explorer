# frozen_string_literal: true

# User model
class User < ApplicationRecord
  acts_as_eventable prefix: 'user', on: %i[create update]
  #acts_as_redpanda_eventable prefix: 'user', on: %i[create update]

  PLATFORM = ['oauth']
  STATE = %w[active deactivated deleted].freeze
  ROLE = %w[institution issuer retailer].freeze
  WEBHOOK_UPDATE_FIELDS = %w[first_name last_name phone_number role otp state applicant_id].freeze

  has_secure_password

  attr_accessor :modify_user
  attr_accessor :remark

  has_many :profiles,                dependent: :destroy
  has_many :phones,                  dependent: :destroy
  has_many :labels,                  dependent: :destroy
  has_many :activities
  has_many :service_accounts,        dependent: :destroy, foreign_key: 'owner_id'
  has_many :api_keys,                dependent: :destroy, as: :key_holder_account, class_name: 'APIKey'
  has_many :user_state_logs,         dependent: :destroy
  has_many :referrals,               foreign_key: 'referral_id', class_name: 'User'
  has_many :medias,                  dependent: :destroy
  has_many :service_logs
  has_many :email_notifications
  has_many :devices,                 dependent: :destroy
  has_many :notification_recipients, dependent: :destroy
  has_many :authorized_clients

  # Add counter cache for referral count
  belongs_to :referrer,           foreign_key: 'referral_id', class_name: 'User', optional: true
  counter_culture :referrer,      column_name: proc {|u| u.state == 'active' ? 'users_count' : nil },
                  column_names: -> { {
                    User.active => :users_count,
                  } }

  validates_length_of :data, maximum: 1024
  validate :role_exists
  validate :referral_exists
  validates :data, data_is_json: true
  validates :email, email: true, presence: true, uniqueness: { case_sensitive: false },
                    if: proc { |a| a.phone_number.nil? || a.email.present? }
  validates :email, undisposable: { message: 'Sorry, but we do not accept your mail provider.' },
                    on: :create,
                    if: -> { Barong::App.config.disable_fake_mail.to_s.to_bool }
  validates :uid,          presence: true, uniqueness: true
  validates :password,     presence: true, if: :should_validate?
  validates :phone_number, phone: true, presence: true, uniqueness: true,
                           if: proc { |a| a.email.nil? || a.phone_number.present? }
  validate  :validate_pass!
  validates :first_name, length: 1..255,
                         format: {
                           with: /\A[[:word:]\s\-']+\z/,
                           message: 'only allows letters, digits "-", "\'", and space'
                         },
                         if: proc { |a| a.first_name.present? }
  validates :last_name, length: 1..255,
                        format: {
                          with: /\A[[:word:]\s\-']+\z/,
                          message: 'only allows letters, digits "-", "\'", and space'
                        },
                        if: proc { |a| a.last_name.present? }
  validates :username, length: 5..255, presence: true, uniqueness: { case_sensitive: false },
                       format: {
                         with: /\A(?=.*[a-zA-Z|0-9])[[:word:]_.]+\z/,
                         message: 'must contain letters or numbers and can include _ or .'
                       }
  before_validation :sanitize_phone_number

  scope :active, -> { where(state: 'active') }

  store_accessor :metadata, %i[code time_before_resend code_expiry_date
                                                 phone_code phone_time_before_resend phone_resend_counter
                                                 phone_code_expiry_date latest_email older_email
                                                 latest_phone older_phone]

  store_accessor :login_metadata, %i[]

  before_validation :assign_uid
  before_validation :generate_password, on: :create
  before_validation :assign_email, on: :create
  before_validation :assign_username, on: :create
  before_validation :assign_referral_code, on: :create
  before_validation :sanitize_email, on: :create

  before_validation do
    self.first_name = first_name&.strip
    self.last_name  = last_name&.strip
    self.username   = username&.strip
    self.platform ||= 'oauth'
  end

  after_update :disable_api_keys
  after_update :disable_service_accounts
  after_commit :update_referrals,  on: :destroy
  after_commit :trigger_webhooks, on: :update

  def update_referrals
    referrals.update_all(referral_id: nil)
  end

  def generate_password
    unless password
      self.password_enabled = false
      self.password         = SecureRandom.base64(30)
    end
  end

  def assign_email
    errors.add(:email_or_phone_number, 'is empty') if email.nil? && phone_number.empty?

    self.email = "pending_user_#{SecureRandom.hex(7)}@blockmaze.network" unless email
  end

  def assign_referral_code
    self.referral_code = SecureRandom.alphanumeric(8)
  end

  def assign_username
    self.username = generate_username unless username
  end

  def validate_pass!
    return unless (new_record? && password.present?) || password.present?

    validation_result = PasswordStrengthChecker.validate!(password)
    errors.add(:password, validation_result) unless validation_result == 'strong'
  end

  def disable_service_accounts
    if state != 'active'
      service_accounts.each do |account|
        account.update(state: state)
      end
    end
  end

  def disable_api_keys
    if otp_previously_changed? && otp == false || state_previously_changed? && state != 'active'
      service_accounts.each do |service_account|
        service_account.api_keys.active.each do |key|
          key.update(state: 'inactive')
        end
      end
      api_keys.active.each do |key|
        key.update(state: 'inactive')
      end
    end
  end

  def active?
    self.state == 'active'
  end

  def superadmin?
    self.role == 'superadmin'
  end

  def role_exists
    return if Permission.pluck(:role).uniq.include?(role)

    errors.add(:role, 'doesnt_exist')
  end

  # Check if refferal exist for assignment
  def referral_exists
    errors.add(:referral_id, 'doesnt_exist') if referral_id.present? && referrer.blank?
  end

  def referrer_uid
    referrer&.uid
  end

  def role
    super.inquiry
  end

  def profile_url
    media = medias.find_by(state: 'active')
    return if media.nil? || media&.moderation_score.to_f >= Barong::App.config.avatar_allowed_moderation_min_confidence.to_f

    media.upload&.url.nil? ? media.image_urls : media.upload
  end

  def profile_type
    medias.find_by(state: 'active')&.type
  end

  def should_validate?
    new_record? || password.present?
  end

  # FIXME: Clean level micro code
  def update_level
    user_level = 0
    tags = labels.with_private_scope.map { |l| [l.key, l.value].join ':' }

    levels = Level.all.order(id: :asc)
    levels.each do |lvl|
      break unless tags.include?("#{lvl.key}:#{lvl.value}")

      user_level = lvl.id
    end

    update(level: user_level)
  end

  def update_label(key, scope: 'private', status: 'verified')
    label = labels.find_or_initialize_by(key: key, scope: scope)
    label.value = status
    label.save!
  end

  def set_code
    update(code: rand.to_s[2..5],
           time_before_resend: 1.minute.from_now,
           code_expiry_date: 5.minutes.from_now)
  end

  def set_phone_code
    update(phone_code: rand.to_s[2..5],
           phone_time_before_resend: 1.minute.from_now,
           phone_code_expiry_date: 5.minutes.from_now,
           phone_resend_counter: self&.phone_resend_counter.to_i + 1)
  end

  def update_state
    @resulting_state = 'pending'

    # check if user has all required labels for activation
    if labels_include?(BarongConfig.list['activation_requirements'])
      @resulting_state = 'active'
    end

    # FIXME BarongConfig should be a feature of Barong::App
    BarongConfig.list['state_triggers']&.each do |state, triggers|
      triggers.each { |trigger|
        labels.pluck(:key).each { |label|
          @resulting_state = state if label.start_with?(trigger)
        }
      }
    end

    update(state: @resulting_state) if @resulting_state != self.state
  end

  # check if given key: values hash is a subset of private user labels
  def labels_include?(labels_hash)
    labels_hash <= private_labels_to_hash
  end

  # Select all key-value pairs from user labels with private scope, merge in one hash
  def private_labels_to_hash
    key_value_arr = self.labels.with_private_scope.map do
      |l| { l.key => l.value }
    end
    key_value_hash = key_value_arr.inject(:merge)
    key_value_hash || {}
  end

  def as_json_for_event_api
    {
      uid: uid,
      name: full_name,
      email: email,
      role: role,
      level: level,
      otp: otp,
      state: state,
      referrer_uid: referrer_uid,
      last_ip: last_ip,
      last_country: last_country,
      created_at: format_iso8601_time(created_at),
      updated_at: format_iso8601_time(updated_at)
    }
  end

  # HotFix: Removing referral_id for websocket private stream issue.
  def as_payload
    as_json(only: %i[uid email role level state last_ip
                     last_country password_reset_at
                     referral_code phone_number users_count
                     first_name last_name username],
            methods: %i[dob referrer_uid])
  end

  def jwt_payload
    as_json(only: %i[uid state])
  end

  def as_json_for_redpanda_api
    {
      uid: uid,
      email: email,
      role: role,
      level: level,
      otp: otp,
      state: state,
      referrer_uid: referrer_uid,
      last_ip: last_ip,
      first_name: first_name,
      last_name: last_name,
      full_name: full_name,
      users_count: users_count,
      phone_number: phone_number,
      last_country: last_country,
      username: username,
      country: country,
      password_reset_at: format_iso8601_time(password_reset_at),
      social_media_status: social_media_status,
      created_at: format_iso8601_time(created_at),
      updated_at: format_iso8601_time(updated_at)
    }
  end

  def webhook_payload
    {
      uid: uid,
      email: filter_email,
      phone_number: phone_number,
      first_name: first_name,
      last_name: last_name,
      full_name: full_name,
      username: username,
      role: role,
      otp: otp,
      state: state,
      institution: institution,
      kyc_status: kyc_status,
      applicant_id: applicant_id
    }.compact
  end

  def language
    if data.blank?
      Barong::App.config.default_language.upcase
    else
      JSON.parse(data)['language']&.upcase || Barong::App.config.default_language.upcase
    end
  end

  def social_profile
    self.profiles&.find_or_create_by(state: 'social')
  end

  def without_social_profile
    profiles.where.not(state: 'social')
  end

  def sub_masked_email
    if filter_email != ''
      email.gsub(/(?<=.{1}).*@.*(?=\S{1})/, '***@****')
    else
      filter_email
    end
  end

  def add_state_log
    past_changes = (previous_changes['state'].present? ? previous_changes['state'][0] : 'no past state given')
    user_state_logs.create!(admin_id: @modify_user, past_state: past_changes, state: state, remark: @remark)
  end

  def sanitize_phone_number
    number            = Phone.international(phone_number)
    self.phone_number = Phone.sanitize(number)
  end

  def remove_plus
    email[/#{Regexp.escape('+')}(.*?)#{Regexp.escape('@')}/m, 0]
  end

  def sanitize_email
    return email unless Barong::App.config.sanitize_email_enabled

    return email unless email.match?(/[+]/)

    self.email = email.gsub(remove_plus, '@')
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def dob
    social_profile&.dob
  end

  def filter_email
    e = self.email.split('@')
    if e[0].match?(/pending_user_/) && e[1].match?(/blockmaze.network/)
      ''
    else
      self.email
    end
  end

  def initial
    name = first_name!
    name.blank? ? '' : name[0, 1]
  end

  # @deprecated
  # TODO:: Remove me as we have implemented the _counter_ cache
  def referrals_count
    referrals.count
  end

  def self.search_query(payload = {})
    matches = []
    payload.except(:order_by, :from, :to, :extended, :range, :page, :limit, :ordering).each do |k, v|
      matches << case k.to_s
                 when 'first_name', 'last_name', 'username', 'uid', 'email', 'country'
                   { wildcard: { k => { value: "*#{v}*", case_insensitive: true } } }
                 when 'referral_id', 'id', 'level'
                   { term: { k => v } }
                 when 'users_count'
                   { range: { k => { gte: "#{v}" } } }
                 else
                   { term: { k => v.downcase } }
                 end
    end

    if payload[:from] && payload[:to]
      matches << { range: { created_at: { gte: payload[:from], lte: payload[:to] } } }
    end

    query = { bool: { must: matches } }
    page = payload[:page] || 1
    limit = payload[:limit] || 20

    sorting_field = payload[:order_by] || 'id'
    sorting_order = payload[:ordering] || 'asc'
    sort = [{ sorting_field => { order: sorting_order } }]
    res = { total: 0 }
    index = UsersIndex.query(query)
    scroll = index.scroll_batches(batch_size: Barong::App.config.batch_size, scroll: Barong::App.config.scroll_time)
    loop do
      response = scroll.next
      res[:total] += response.count

      break unless response.any?
    end
    res[:records] = index.limit(limit).offset((page - 1) * limit).order(sort).objects
    res
  end

  def self.search_users(payload)
    matches = []
    payload.each do |k, values|
      matches << { terms: { k => values }}
    end
    query = { bool: { should: matches } }
    UsersIndex.query(query)
  end

  def get_referrals
    User.search_query({referral_id: id,
                       limit: rand(Barong::App.config.public_referrals_min_profile
                                              .to_i..Barong::App.config.public_referrals_max_profile.to_i)})[:records]
  end

  def email_notification(name)
    email_type = EmailType.find_by(name: name)
    return unless email_type.present?

    email_notifications.find_or_initialize_by(email: email, email_type: email_type)
  end

  def self.underage?(dob, platform)
    return if platform == 'app'

    DateTime.parse(dob) + Barong::App.config.minimum_age_to_register.years > Time.zone.today
  end

  def verified
    level == Barong::App.config.kyc_level
  end

  def update_clients
    RegisteredClient.active.each do |client|
      ::UserUpdate.perform_async({ id: id, client_id: client.id }.to_json)
    end
  end

  def kyc_status
    labels.find_by(key: 'document', scope: 'private')&.value
  end

  private

  def trigger_webhooks
    changed = saved_changes.keys & WEBHOOK_UPDATE_FIELDS
    return if changed.empty?

    update_clients
  end

  def assign_uid
    return unless uid.blank?

    self.uid = Barong::App.config.uid_prefix + SecureRandom.uuid
  end

  def generate_username
    ((first_name! || 'user') + (last_name || ''))[0..22] + rand.to_s[2..8]
  end

  def from_email
    email = filter_email.split('@')
    return '' if email.empty?

    email[0]
  end

  def first_name!
    sanitize_email
    fe = from_email
    first_name || (fe == '' ? nil :  fe)
  end
end

# == Schema Information
# Schema version: 20251216075339
#
# Table name: users
#
#  id                  :bigint           not null, primary key
#  uid                 :string(255)      not null
#  email               :string(255)      not null
#  phone_number        :string(255)
#  first_name          :string(255)
#  last_name           :string(255)
#  username            :string(255)
#  password_digest     :string(255)      not null
#  password_enabled    :boolean          default(TRUE)
#  role                :string(255)      default("member"), not null
#  institution         :string(255)
#  platform            :string(255)
#  data                :text(65535)
#  level               :integer          default(0), not null
#  applicant_id        :string(255)
#  otp                 :boolean          default(FALSE)
#  state               :string(255)      default("pending"), not null
#  referral_id         :bigint
#  referral_code       :string(255)
#  users_count         :integer          default(0), not null
#  metadata            :json
#  country             :string(255)
#  last_ip             :string(255)      default("0.0.0.0"), not null
#  last_country        :string(255)
#  password_reset_at   :datetime         default(Sun, 02 Feb 1947 00:00:00 UTC +00:00)
#  social_media_status :string(255)      default("active")
#  status_updated_at   :datetime         default(Sun, 02 Feb 1947 00:00:00 UTC +00:00)
#  login_metadata      :json
#  general_info        :text(65535)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_users_on_email          (email) UNIQUE
#  index_users_on_phone_number   (phone_number)
#  index_users_on_platform       (platform)
#  index_users_on_referral_code  (referral_code) UNIQUE
#  index_users_on_state          (state)
#  index_users_on_uid            (uid) UNIQUE
#  index_users_on_username       (username) UNIQUE
#
