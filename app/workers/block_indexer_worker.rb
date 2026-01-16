class BlockIndexerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 5

  def perform(block_number)
    Indexer::IndexBlockService.call(block_number)
  end
end
