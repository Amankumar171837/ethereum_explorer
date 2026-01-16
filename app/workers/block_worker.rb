class BlockWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: false

  def perform
    require 'sidekiq/api'
    
    # Don't flood the queue. Only enqueue if queue is relatively small.
    queue_size = Sidekiq::Queue.new.size
    if queue_size > 500
      Rails.logger.info "BlockWorker: Queue size is #{queue_size}, waiting for workers..."
      self.class.perform_in(10.seconds)
      return
    end

    rpc = Ethereum::RpcClient.instance
    start_block = ENV.fetch('START_BLOCK', 0).to_i
    
    latest = rpc.eth_block_number
    max_indexed = Block.maximum(:number) || (start_block - 1)
    
    # Get last enqueued block from Redis to avoid duplicates
    last_enqueued = Sidekiq.redis { |conn| conn.get("indexer:last_enqueued_block") }.to_i
    
    # We start from the maximum of (max_indexed, last_enqueued)
    last = [max_indexed, last_enqueued].max

    if last < latest
      # Batch enqueue next 20 blocks
      limit = 20
      target = [last + limit, latest].min
      
      (last + 1..target).each do |n|
        BlockIndexerWorker.perform_async(n)
      end
      
      # Update last enqueued block in Redis
      Sidekiq.redis { |conn| conn.set("indexer:last_enqueued_block", target, ex: 3600) }
      
      Rails.logger.info "BlockWorker: Enqueued blocks #{last + 1} to #{target} (Latest: #{latest})"
    else
      Rails.logger.info "BlockWorker: Synced to tip: #{latest}"
    end

    # Self-schedule for next run
    self.class.perform_in(10.seconds)
  end
end