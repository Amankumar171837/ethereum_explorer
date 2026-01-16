namespace :indexer do
  desc "Start the block indexer loop"
  task start: :environment do
    require 'sidekiq/api'
    Dotenv.load if defined?(Dotenv)
    rpc = Ethereum::RpcClient.instance
    
    puts "Starting Ethereum Indexer..."
    start_block = ENV.fetch('START_BLOCK', 0).to_i
    puts "Configured START_BLOCK: #{start_block}"
    
    loop do
      begin
        latest_block = rpc.eth_block_number
        max_indexed = Block.maximum(:number)
        
        # If DB is empty or max indexed is behind our start block, jump to start block
        last_indexed = if max_indexed.nil? || max_indexed < (start_block - 1)
                         start_block - 1
                       else
                         max_indexed
                       end
        
        if last_indexed < latest_block
          # Don't flood the queue. Only enqueue if queue is relatively small.
          queue_size = Sidekiq::Queue.new.size
          if queue_size > 1000
            puts "Queue size is #{queue_size}, waiting for workers..."
            sleep 5
            next
          end

          # Enqueue next batch
          limit = 100
          target = [last_indexed + limit, latest_block].min
          
          (last_indexed + 1..target).each do |block_number|
            BlockIndexerWorker.perform_async(block_number)
          end
          
          puts "Enqueued blocks #{last_indexed + 1} to #{target} (Latest: #{latest_block})"
          sleep 1 # Give Sidekiq a moment to start processing
        else
          puts "Synced to tip: #{latest_block}. Sleeping..."
          sleep 10
        end
      rescue StandardError => e
        puts "Indexer error: #{e.message}"
        sleep 5
      end
    end
  end
end
