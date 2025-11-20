class UserStateLog < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: 'User', foreign_key: 'admin_id'
  validates :user_id, :admin_id, :past_state, :state, :remark, presence: true

  def change_by_user_email
    admin.email
  end

  def change_by_user_uid
    admin.uid
  end
end

# == Schema Information
# Schema version: 20210915103231
#
# Table name: user_state_logs
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           unsigned, not null
#  admin_id   :bigint           not null
#  past_state :string(255)      not null
#  state      :string(255)      not null
#  remark     :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_state_logs_on_user_id  (user_id)
#
