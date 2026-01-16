class Transaction < ApplicationRecord
  self.primary_key = :transaction_hash
  belongs_to :block, foreign_key: :block_number, primary_key: :number, inverse_of: :transactions
  has_many :logs, foreign_key: :transaction_hash, primary_key: :transaction_hash, inverse_of: :transaction_record
  has_many :token_transfers, foreign_key: :transaction_hash, primary_key: :transaction_hash, inverse_of: :transaction_record
  
  belongs_to :from_address_record, class_name: 'Address', foreign_key: :from_address, primary_key: :address, optional: true
  belongs_to :to_address_record, class_name: 'Address', foreign_key: :to_address, primary_key: :address, optional: true
  belongs_to :contract_address_record, class_name: 'Address', foreign_key: :contract_address, primary_key: :address, optional: true

  validates :transaction_hash, presence: true, uniqueness: true

end
