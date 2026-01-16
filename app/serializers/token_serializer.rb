class TokenSerializer < ActiveModel::Serializer
  attributes :address, :name, :symbol, :decimals, :total_supply, :token_type, :holder_count, :transfer_count
end
