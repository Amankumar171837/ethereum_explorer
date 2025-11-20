# frozen_string_literal: true

class UsersIndex < Chewy::Index
  settings analysis: {
    analyzer: {
      email: {
        tokenizer: 'keyword',
        type: 'keyword'
      }
    }
  }

  index_scope User
  root date_detection: true do
    field :first_name
    field :last_name
    field :state
    field :phone_number
    field :username
    field :email, analyzer: 'email'
    field :uid, type: 'keyword'
    field :role
    field :platform
    field :referral_id, type: 'integer'
    field :id, type: 'integer'
    field :country
    field :level, type: 'integer'
    field :users_count, type: 'integer'
    field :created_at, type: 'date', format: "yyyy-MM-dd HH:mm:ss||strict_date_optional_time ||epoch_millis"
    field :updated_at, type: 'date', format: "yyyy-MM-dd HH:mm:ss||strict_date_optional_time||epoch_millis"
  end
end
