class Contract < ApplicationRecord
  belongs_to :address_record, class_name: 'Address', foreign_key: :address, primary_key: :address, inverse_of: :contract
  belongs_to :creator, class_name: 'Address', foreign_key: :creator_address, primary_key: :address, optional: true
  belongs_to :creation_transaction, class_name: 'Transaction', foreign_key: :creation_transaction_hash, primary_key: :transaction_hash, optional: true
  belongs_to :creation_block, class_name: 'Block', foreign_key: :creation_block_number, primary_key: :number, optional: true
end
