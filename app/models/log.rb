class Log < ApplicationRecord
  belongs_to :block, foreign_key: :block_number, primary_key: :number, inverse_of: :logs, optional: true
  belongs_to :transaction_record, class_name: 'Transaction', foreign_key: :transaction_hash, primary_key: :transaction_hash, inverse_of: :logs, optional: true
  belongs_to :address_record, class_name: 'Address', foreign_key: :address, primary_key: :address, optional: true
end
