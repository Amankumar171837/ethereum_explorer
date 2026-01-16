module Indexer
  class IndexLogService
    def self.call(log_data, transaction)
      new(log_data, transaction).call
    end

    def initialize(log_data, transaction)
      @log_data = log_data
      @transaction = transaction
    end

    def call
      # Save log
      log = save_log

      # Decode token transfers
      IndexTokenTransferService.call(log) if token_transfer?(log)

      log
    end

    private

    def save_log
      Log.find_or_create_by!(
        block_number: @transaction.block_number,
        transaction_index: @transaction.transaction_index,
        log_index: hex_to_int(@log_data['logIndex'])
      ) do |log|
        log.block_hash = @transaction.block_hash
        log.transaction_hash = @transaction.transaction_hash
        log.address = normalize_address(@log_data['address'])
        log.data = @log_data['data']
        log.topic0 = @log_data['topics'][0]
        log.topic1 = @log_data['topics'][1]
        log.topic2 = @log_data['topics'][2]
        log.topic3 = @log_data['topics'][3]
        log.removed = @log_data['removed'] || false
      end
    end

    def token_transfer?(log)
      # ERC-20/721 Transfer: Transfer(address,address,uint256)
      # ERC-1155 TransferSingle: TransferSingle(address,address,address,uint256,uint256)
      [
        '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef', # Transfer
        '0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62'  # TransferSingle
      ].include?(log.topic0)
    end

    def normalize_address(addr)
      addr&.downcase
    end

    def hex_to_int(hex)
      hex ? hex.to_i(16) : nil
    end
  end
end
