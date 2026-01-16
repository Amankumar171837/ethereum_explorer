module Indexer
  class IndexTransactionService
    def self.call(tx_data, block)
      new(tx_data, block).call
    end

    def initialize(tx_data, block)
      @tx_data = tx_data
      @block = block
      @rpc_client = Ethereum::RpcClient.instance
    end

    def call
      # Fetch receipt for status and logs
      receipt = @rpc_client.eth_get_transaction_receipt(@tx_data['hash'])
      return unless receipt

      retries = 0
      begin
        ActiveRecord::Base.transaction do
          # Save transaction
          transaction = save_transaction(receipt)

          # Update addresses
          update_addresses(transaction)

          # Index logs
          if receipt['logs'].is_a?(Array)
            receipt['logs'].each do |log_data|
              IndexLogService.call(log_data, transaction)
            end
          end

          transaction
        end
      rescue ActiveRecord::Deadlocked, ActiveRecord::LockWaitTimeout, Mysql2::Error::TimeoutError
        if retries < 3
          retries += 1
          sleep(0.1 * retries)
          retry
        else
          raise
        end
      end
    end

    private

    def save_transaction(receipt)
      Transaction.find_or_create_by!(transaction_hash: @tx_data['hash']) do |tx|
        tx.block_number = @block.number
        tx.block_hash = @block.block_hash
        tx.transaction_index = hex_to_int(@tx_data['transactionIndex'])
        tx.from_address = normalize_address(@tx_data['from'])
        tx.to_address = normalize_address(@tx_data['to'])
        tx.value = hex_to_int(@tx_data['value']).to_s
        tx.gas = hex_to_int(@tx_data['gas'])
        tx.gas_price = hex_to_int(@tx_data['gasPrice'])
        tx.max_fee_per_gas = hex_to_int(@tx_data['maxFeePerGas'])
        tx.max_priority_fee_per_gas = hex_to_int(@tx_data['maxPriorityFeePerGas'])
        tx.input = @tx_data['input']
        tx.nonce = hex_to_int(@tx_data['nonce'])
        tx.status = hex_to_int(receipt['status'])
        tx.gas_used = hex_to_int(receipt['gasUsed'])
        tx.cumulative_gas_used = hex_to_int(receipt['cumulativeGasUsed'])
        tx.effective_gas_price = hex_to_int(receipt['effectiveGasPrice'])
        tx.contract_address = normalize_address(receipt['contractAddress'])
        tx.transaction_type = hex_to_int(@tx_data['type']) || 0
      end
    end

    def update_addresses(transaction)
      # Update from address
      Address.find_or_create_by!(address: transaction.from_address) do |addr|
        addr.first_seen_block = @block.number
      end
      
      Address.where(address: transaction.from_address).update_all([
        "last_seen_block = GREATEST(last_seen_block, ?), transaction_count = transaction_count + 1",
        @block.number
      ])

      # Update to address
      if transaction.to_address.present?
        Address.find_or_create_by!(address: transaction.to_address) do |addr|
          addr.first_seen_block = @block.number
        end
        
        Address.where(address: transaction.to_address).update_all([
          "last_seen_block = GREATEST(last_seen_block, ?)",
          @block.number
        ])
      end

      # Handle contract creation
      if transaction.contract_address.present?
        Address.find_or_create_by!(address: transaction.contract_address) do |addr|
          addr.is_contract = true
          addr.contract_creator = transaction.from_address
          addr.contract_creation_tx = transaction.transaction_hash
          addr.contract_creation_block = @block.number
          addr.first_seen_block = @block.number
        end
      end
    end

    def normalize_address(addr)
      addr&.downcase
    end

    def hex_to_int(hex)
      hex ? hex.to_i(16) : nil
    end
  end
end
