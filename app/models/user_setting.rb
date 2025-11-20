# frozen_string_literal: true

class UserSetting < ApplicationRecord

  # == Constants ============================================================

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  belongs_to :user

  # == Validations ==========================================================

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

end

# == Schema Information
# Schema version: 20230824100354
#
# Table name: user_settings
#
#  id                   :bigint           not null, primary key
#  user_id              :bigint
#  username_updated     :datetime         default(Sun, 02 Feb 1947 00:00:00 UTC +00:00)
#  email_updated        :datetime         default(Sun, 02 Feb 1947 00:00:00 UTC +00:00)
#  phone_number_updated :datetime         default(Sun, 02 Feb 1947 00:00:00 UTC +00:00)
#  metadata             :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_user_settings_on_user_id  (user_id)
#
