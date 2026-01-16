class TransactionSerializer < ActiveModel::Serializer
  attributes :transaction_hash, :block_number, :from_address, :to_address, :value,
             :gas, :gas_price, :gas_used, :status, :input, :contract_address, :timestamp, :block, :logs, :token_transfers

  def hash
    object.transaction_hash
  end

  belongs_to :block, if: :include_block?

  def include_block?
    instance_options[:include_block]
  end

  def timestamp
    object.block&.timestamp
  end
end
