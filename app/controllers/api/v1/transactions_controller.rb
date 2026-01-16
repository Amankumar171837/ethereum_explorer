module Api
  module V1
    class TransactionsController < ApplicationController
      # GET /api/v1/transactions
      def index
        @transactions = Transaction.includes(:block)
                                   .order(block_number: :desc, transaction_index: :desc)
                                   .page(params[:page])
                                   .per(params[:per_page] || 25)

        render json: @transactions, each_serializer: TransactionSerializer, meta: pagination_meta(@transactions)
      end

      # GET /api/v1/transactions/:hash
      def show
        @transaction = Transaction.includes(:block, :logs).find_by(transaction_hash: params[:hash])
        
        if @transaction
          render json: @transaction, serializer: TransactionSerializer, include_logs: true
        else
          render json: { error: 'Transaction not found' }, status: :not_found
        end
      end

      private

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
