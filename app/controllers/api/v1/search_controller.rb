module Api
  module V1
    class SearchController < ApplicationController
      def index
        query = params[:q].to_s.strip
        
        if query.blank?
          return render json: { error: 'Query parameter "q" is required' }, status: :bad_request
        end

        result = perform_search(query)

        if result
          render json: result
        else
          render json: { error: 'No results found' }, status: :not_found
        end
      end

      private

      def perform_search(query)
        # 1. Check if it's a block number
        if query =~ /^\d+$/
          block = Block.find_by(number: query.to_i)
          return { type: 'block', data: BlockSerializer.new(block) } if block
        end

        # 2. Check if it's a hash (66 chars starting with 0x)
        if query =~ /^0x[a-fA-F0-9]{64}$/
          # Check Transaction first (more common)
          tx = Transaction.find_by(transaction_hash: query.downcase)
          return { type: 'transaction', data: TransactionSerializer.new(tx) } if tx

          # Check Block hash
          block = Block.find_by(block_hash: query.downcase)
          return { type: 'block', data: BlockSerializer.new(block) } if block
        end

        # 3. Check if it's an address (42 chars starting with 0x)
        if query =~ /^0x[a-fA-F0-9]{40}$/
          normalized_addr = query.downcase
          
          # Check Token first
          token = Token.find_by(address: normalized_addr)
          return { type: 'token', data: TokenSerializer.new(token) } if token

          # Check Address
          address = Address.find_by(address: normalized_addr)
          return { type: 'address', data: AddressSerializer.new(address) } if address
        end

        nil
      end
    end
  end
end
