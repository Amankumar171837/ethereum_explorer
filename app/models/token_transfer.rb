class TokenTransfer < ApplicationRecord
  belongs_to :token, foreign_key: :token_address, primary_key: :address, inverse_of: :transfers, optional: true
  belongs_to :transaction_record, class_name: 'Transaction', foreign_key: :transaction_hash, primary_key: :transaction_hash, inverse_of: :token_transfers, optional: true
  belongs_to :block, foreign_key: :block_number, primary_key: :number, inverse_of: :token_transfers, optional: true
  
  belongs_to :from_address_record, class_name: 'Address', foreign_key: :from_address, primary_key: :address, optional: true
  belongs_to :to_address_record, class_name: 'Address', foreign_key: :to_address, primary_key: :address, optional: true
end
