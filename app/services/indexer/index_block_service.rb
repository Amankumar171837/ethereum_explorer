module Indexer
  class IndexBlockService
    def self.call(block_number)
      new(block_number).call
    end

    def initialize(block_number)
      @block_number = block_number
      @rpc_client = Ethereum::RpcClient.instance
    end

    def call
      # Fetch block from node
      block_data = @rpc_client.eth_get_block_by_number(@block_number, true)
      return unless block_data

      # Save block first in its own transaction
      block = ActiveRecord::Base.transaction do
        save_block(block_data)
      end

      # Index transactions individually (each will have its own transaction)
      if block_data['transactions'].is_a?(Array)
        block_data['transactions'].each do |tx_data|
          IndexTransactionService.call(tx_data, block)
        end
        
        # Update block transaction count
        block.update!(transaction_count: block_data['transactions'].size)
      end

      Rails.logger.info "Indexed block #{@block_number}"
    rescue StandardError => e
      Rails.logger.error "Failed to index block #{@block_number}: #{e.message}"
      raise
    end

    private

    def save_block(data)
      Block.find_or_create_by!(number: hex_to_int(data['number'])) do |block|
        block.block_hash = data['hash']
        block.parent_hash = data['parentHash']
        block.timestamp = hex_to_int(data['timestamp'])
        block.miner = data['miner']
        block.difficulty = hex_to_int(data['difficulty']).to_s
        block.total_difficulty = hex_to_int(data['totalDifficulty']).to_s
        block.size = hex_to_int(data['size'])
        block.gas_used = hex_to_int(data['gasUsed'])
        block.gas_limit = hex_to_int(data['gasLimit'])
        block.base_fee_per_gas = hex_to_int(data['baseFeePerGas'])
        block.transactions_root = data['transactionsRoot']
        block.state_root = data['stateRoot']
        block.receipts_root = data['receiptsRoot']
        block.extra_data = data['extraData']
        block.nonce = data['nonce']
        block.indexed_at = Time.current
      end
    end

    def hex_to_int(hex)
      hex ? hex.to_i(16) : nil
    end
  end
end
