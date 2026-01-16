class TokenTransferSerializer < ActiveModel::Serializer
  attributes :transaction_hash, :block_number, :from_address, :to_address, :value, :token_id, :amount, :timestamp, :token_address

  belongs_to :token
end
