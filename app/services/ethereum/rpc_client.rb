require 'singleton'

module Ethereum
  class RpcClient
    include Singleton

    def initialize
      @url = ENV.fetch('ETHEREUM_RPC_URL', 'http://localhost:8545')
      @conn = Faraday.new(url: @url) do |f|
        f.request :json
        f.response :json
        f.adapter Faraday.default_adapter
      end
    end

    def eth_block_number
      response = rpc_call('eth_blockNumber', [])
      response.to_i(16)
    end

    def eth_get_block_by_number(number, full_tx = true)
      hex = "0x#{number.to_s(16)}"
      rpc_call('eth_getBlockByNumber', [hex, full_tx])
    end

    def eth_get_transaction_receipt(hash)
      rpc_call('eth_getTransactionReceipt', [hash])
    end

    private

    def rpc_call(method, params)
      response = @conn.post('', {
        jsonrpc: '2.0',
        method: method,
        params: params,
        id: 1
      })
      
      if response.body['error']
        raise "RPC Error: #{response.body['error']['message']}"
      end

      response.body['result']
    end
  end
end
