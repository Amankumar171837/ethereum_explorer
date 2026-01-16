class AddressSerializer < ActiveModel::Serializer
  attributes :address, :balance, :transaction_count, :is_contract, :first_seen_block, :last_seen_block, :transactions
end
