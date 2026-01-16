module Api
  module V1
    class TokensController < ApplicationController
      # GET /api/v1/tokens
      def index
        @tokens = Token.order(holder_count: :desc)
                       .page(params[:page])
                       .per(params[:per_page] || 25)

        render json: @tokens, each_serializer: TokenSerializer, meta: pagination_meta(@tokens)
      end

      # GET /api/v1/tokens/:address
      def show
        @token = Token.find_by(address: params[:address].downcase)
        
        if @token
          render json: @token, serializer: TokenSerializer
        else
          render json: { error: 'Token not found' }, status: :not_found
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
