class Block < ApplicationRecord
  has_many :transactions, foreign_key: :block_number, primary_key: :number, inverse_of: :block
  has_many :logs, foreign_key: :block_number, primary_key: :number, inverse_of: :block
  has_many :token_transfers, foreign_key: :block_number, primary_key: :number, inverse_of: :block
  belongs_to :miner_address_record, class_name: 'Address', foreign_key: :miner, primary_key: :address, optional: true

  validates :number, presence: true, uniqueness: true
  validates :block_hash, presence: true, uniqueness: true
end
