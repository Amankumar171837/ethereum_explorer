class ReorgCheckerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :critical, retry: false

  def perform
    # Check last 12 blocks (typical confirmation depth) for re-orgs
    # We only check blocks that we have marked as canonical
    Block.where(is_canonical: true)
         .order(number: :desc)
         .limit(12)
         .each do |block|
      
      # Fetch the block from the node again
      node_block = Ethereum::RpcClient.instance.eth_get_block_by_number(block.number, false)
      
      if node_block.nil?
        Rails.logger.warn "Block #{block.number} not found on node during re-org check"
        next
      end

      # If the hash on the node is different from what we have, it's a re-org
      if node_block['hash'] != block.block_hash
        Rails.logger.warn "RE-ORG DETECTED at block #{block.number}! Old: #{block.block_hash}, New: #{node_block['hash']}"
        handle_reorg(block.number)
        break # Stop checking, we'll re-index from here
      end
    end
  end

  private

  def handle_reorg(block_number)
    ActiveRecord::Base.transaction do
      # 1. Mark all blocks from this height onwards as non-canonical
      # We don't delete them immediately to keep a history of orphaned blocks (optional)
      # or we can just delete them. For simplicity here, we'll delete to avoid unique constraint issues on re-indexing
      # if our unique index is only on (number).
      # But our schema has unique index on (number) and (hash).
      # If we keep them, we need to update the unique constraint to be (number, hash) or (number, is_canonical).
      # Our schema: t.bigint :number, null: false, index: { unique: true }
      # So we MUST delete or update the number to something else (e.g. negative) to allow re-indexing.
      
      # Strategy: Delete the orphaned blocks and their data (cascading delete)
      blocks_to_remove = Block.where('number >= ?', block_number)
      count = blocks_to_remove.count
      blocks_to_remove.destroy_all
      
      Rails.logger.info "Re-org: Removed #{count} orphaned blocks starting from #{block_number}"
    end

    # 2. Trigger re-indexing from this block
    # The indexer loop will naturally pick this up because the max block number in DB has decreased.
    Rails.logger.info "Re-org: Indexer will pick up from block #{block_number} automatically."
  end
end
