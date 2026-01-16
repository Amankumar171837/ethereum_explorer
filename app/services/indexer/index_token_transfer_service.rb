module Indexer
  class IndexTokenTransferService
    ERC20_TRANSFER = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'
    ERC1155_SINGLE = '0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62'
    ERC1155_BATCH = '0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb'

    def self.call(log)
      new(log).call
    end

    def initialize(log)
      @log = log
    end

    def call
      case @log.topic0
      when ERC20_TRANSFER
        decode_erc20_transfer
      when ERC1155_SINGLE
        decode_erc1155_single
      when ERC1155_BATCH
        decode_erc1155_batch
      end
    end

    private

    def decode_erc20_transfer
      from = decode_address(@log.topic1)
      to = decode_address(@log.topic2)
      decode_uint256(@log.topic3 || @log.data)

      # Determine token type (ERC-20 vs ERC-721)
      # Heuristic: if value is huge, it's likely ERC20 amount. If small and unique, maybe ERC721.
      # But strictly, ERC721 Transfer is indexed from, indexed to, indexed tokenId.
      # ERC20 Transfer is indexed from, indexed to, value (not indexed).
      # If topic3 is present, it's ERC721 (tokenId is indexed).
      # If topic3 is nil, it's ERC20 (value is in data).
      
      if @log.topic3.present?
        token_type = 'ERC721'
        token_id = decode_uint256(@log.topic3)
        amount = nil
      else
        token_type = 'ERC20'
        token_id = nil
        amount = decode_uint256(@log.data)
      end

      # Ensure token exists
      token = ensure_token(@log.address, token_type)

      # Save transfer
      TokenTransfer.find_or_create_by!(
        transaction_hash: @log.transaction_hash,
        log_index: @log.log_index
      ) do |tt|
        tt.block_number = @log.block_number
        tt.token_address = @log.address
        tt.token_type = token_type
        tt.from_address = from
        tt.to_address = to
        tt.value = (token_type == 'ERC20' ? amount : nil)
        tt.token_id = token_id
        tt.timestamp = @log.block.timestamp
      end

      # Update token stats
      update_token_stats(token)
    end

    def decode_erc1155_single
      from = decode_address(@log.topic2)
      to = decode_address(@log.topic3)
      
      # Data contains: id (32 bytes) + value (32 bytes)
      # Remove 0x prefix
      data = @log.data.sub(/^0x/, '')
      token_id = data[0...64].to_i(16)
      amount = data[64...128].to_i(16)

      token = ensure_token(@log.address, 'ERC1155')

      TokenTransfer.find_or_create_by!(
        transaction_hash: @log.transaction_hash,
        log_index: @log.log_index
      ) do |tt|
        tt.block_number = @log.block_number
        tt.token_address = @log.address
        tt.token_type = 'ERC1155'
        tt.from_address = from
        tt.to_address = to
        tt.token_id = token_id
        tt.amount = amount
        tt.timestamp = @log.block.timestamp
      end

      update_token_stats(token)
    end

    def decode_erc1155_batch
      # Placeholder for batch decoding
    end

    def decode_address(topic)
      return nil if topic.nil?
      '0x' + topic[-40..-1]  # Last 20 bytes
    end

    def decode_uint256(hex)
      return 0 if hex.nil?
      hex.to_i(16)
    end

    def ensure_token(address, token_type)
      retries = 0
      begin
        Token.find_or_create_by!(address: address) do |token|
          token.token_type = token_type
          token.first_seen_block = @log.block_number
        end
      rescue ActiveRecord::Deadlocked, ActiveRecord::LockWaitTimeout
        if retries < 3
          retries += 1
          sleep(0.1 * retries)
          retry
        else
          raise
        end
      end
    end

    def update_token_stats(token)
      retries = 0
      begin
        Token.where(id: token.id).update_all("transfer_count = transfer_count + 1")
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
  end
end
