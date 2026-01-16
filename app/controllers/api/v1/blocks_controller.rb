module Api
  module V1
    class BlocksController < ApplicationController
      # GET /api/v1/blocks
      def index
        @blocks = Block.where(is_canonical: true)
                       .order(number: :desc)
                       .page(params[:page])
                       .per(params[:per_page] || 25)

        render json: @blocks, each_serializer: BlockSerializer, meta: pagination_meta(@blocks)
      end

      # GET /api/v1/blocks/:number_or_hash
      def show
        @block = find_block(params[:number_or_hash])
        
        if @block
          render json: @block, serializer: BlockSerializer, include_transactions: true
        else
          render json: { error: 'Block not found' }, status: :not_found
        end
      end

      private

      def find_block(identifier)
        if identifier.to_s.start_with?('0x') && identifier.to_s.length == 66
          Block.find_by(block_hash: identifier)
        else
          Block.find_by(number: identifier.to_i)
        end
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          per_page: collection.limit_value
        }
      end
    end
  end
end
