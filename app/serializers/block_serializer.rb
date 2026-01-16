class BlockSerializer < ActiveModel::Serializer
  attributes :number, :block_hash, :parent_hash, :timestamp, :miner, :difficulty,
             :size, :gas_used, :gas_limit, :base_fee_per_gas, :transaction_count, :transactions, :logs, :token_transfers

  def hash
    object.block_hash
  end

  has_many :transactions, if: :include_transactions?

  def include_transactions?
    instance_options[:include_transactions]
  end
end
