class Address < ApplicationRecord
  has_one :contract, foreign_key: :address, primary_key: :address, inverse_of: :address_record
  has_many :logs, foreign_key: :address, primary_key: :address, inverse_of: :address_record
  
  has_many :sent_transactions, class_name: 'Transaction', foreign_key: :from_address, primary_key: :address, inverse_of: :from_address_record
  has_many :received_transactions, class_name: 'Transaction', foreign_key: :to_address, primary_key: :address, inverse_of: :to_address_record
  
  has_many :sent_token_transfers, class_name: 'TokenTransfer', foreign_key: :from_address, primary_key: :address, inverse_of: :from_address_record
  has_many :received_token_transfers, class_name: 'TokenTransfer', foreign_key: :to_address, primary_key: :address, inverse_of: :to_address_record
  
  has_many :mined_blocks, class_name: 'Block', foreign_key: :miner, primary_key: :address, inverse_of: :miner_address_record
  
  validates :address, presence: true, uniqueness: true
  
end
