module Api
  module V1
    class AddressesController < ApplicationController
      before_action :set_address

      # GET /api/v1/addresses/:address
      def show
        render json: @address, serializer: AddressSerializer
      end

      # GET /api/v1/addresses/:address/transactions
      def transactions
        @transactions = Transaction.where('from_address = ? OR to_address = ?', @address.address, @address.address)
                                   .order(block_number: :desc)
                                   .page(params[:page])
                                   .per(params[:per_page] || 25)

        render json: @transactions, each_serializer: TransactionSerializer, meta: pagination_meta(@transactions)
      end

      # GET /api/v1/addresses/:address/token_transfers
      def token_transfers
        @transfers = TokenTransfer.where('from_address = ? OR to_address = ?', @address.address, @address.address)
                                  .includes(:token)
                                  .order(block_number: :desc)
                                  .page(params[:page])
                                  .per(params[:per_page] || 25)

        render json: @transfers, each_serializer: TokenTransferSerializer, meta: pagination_meta(@transfers)
      end

      private

      def set_address
        @address = Address.find_by(address: params[:address].downcase)
        unless @address
          render json: { error: 'Address not found' }, status: :not_found
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
