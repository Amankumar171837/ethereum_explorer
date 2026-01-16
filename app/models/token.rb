class Token < ApplicationRecord
  self.primary_key = :address
  has_many :transfers, class_name: 'TokenTransfer', foreign_key: :token_address, primary_key: :address, inverse_of: :token
  belongs_to :address_record, class_name: 'Address', foreign_key: :address, primary_key: :address, optional: true

  validates :address, presence: true, uniqueness: true
  validates :token_type, presence: true
end
