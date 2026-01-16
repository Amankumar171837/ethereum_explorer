class CreateEthereumExplorerTables < ActiveRecord::Migration[7.1]
  def change
    create_table :blocks, id: false, primary_key: :id do |t|
      t.bigint :id, null: false, auto_increment: true, primary_key: true
      t.bigint :number, null: false, index: { unique: true }
      t.string :block_hash, limit: 66, null: false, index: { unique: true }
      t.string :parent_hash, limit: 66, null: false
      t.bigint :timestamp, null: false, index: true
      t.string :miner, limit: 42, null: false, index: true
      t.string :difficulty, limit: 78
      t.string :total_difficulty, limit: 78
      t.bigint :size
      t.bigint :gas_used
      t.bigint :gas_limit
      t.bigint :base_fee_per_gas
      t.string :transactions_root, limit: 66
      t.string :state_root, limit: 66
      t.string :receipts_root, limit: 66
      t.text :extra_data
      t.string :nonce, limit: 18
      t.integer :transaction_count, default: 0, unsigned: true
      t.datetime :indexed_at, null: false
      t.boolean :is_canonical, default: true
      t.timestamps
    end
    add_index :blocks, [:is_canonical, :number]

    create_table :transactions, id: false, primary_key: :id do |t|
      t.bigint :id, null: false, auto_increment: true, primary_key: true
      t.string :transaction_hash, limit: 66, null: false, index: { unique: true }
      t.bigint :block_number, null: false, index: true
      t.string :block_hash, limit: 66, null: false
      t.integer :transaction_index, null: false, unsigned: true
      t.string :from_address, limit: 42, null: false, index: true
      t.string :to_address, limit: 42, index: true
      t.string :value, limit: 78, default: "0", null: false
      t.bigint :gas, null: false
      t.bigint :gas_price
      t.bigint :max_fee_per_gas
      t.bigint :max_priority_fee_per_gas
      t.text :input
      t.bigint :nonce, null: false
      t.integer :status, limit: 1, unsigned: true
      t.bigint :gas_used
      t.bigint :cumulative_gas_used
      t.bigint :effective_gas_price
      t.string :contract_address, limit: 42, index: true
      t.integer :transaction_type, limit: 1, default: 0, unsigned: true
      t.timestamps
    end
    add_index :transactions, [:block_number, :transaction_index]
    add_foreign_key :transactions, :blocks, column: :block_number, primary_key: :number, on_delete: :cascade

    create_table :addresses, id: false, primary_key: :id do |t|
      t.bigint :id, null: false, auto_increment: true, primary_key: true
      t.string :address, limit: 42, null: false, index: { unique: true }
      t.boolean :is_contract, default: false, index: true
      t.string :balance, limit: 78, default: "0"
      t.datetime :balance_updated_at
      t.bigint :transaction_count, default: 0, unsigned: true
      t.bigint :first_seen_block, index: true
      t.bigint :last_seen_block
      t.string :contract_creator, limit: 42
      t.string :contract_creation_tx, limit: 66
      t.bigint :contract_creation_block
      t.timestamps
    end

    create_table :logs, id: false, primary_key: :id do |t|
      t.bigint :id, null: false, auto_increment: true, primary_key: true
      t.bigint :block_number, null: false, index: true
      t.string :block_hash, limit: 66, null: false
      t.string :transaction_hash, limit: 66, null: false, index: true
      t.integer :transaction_index, null: false, unsigned: true
      t.integer :log_index, null: false, unsigned: true
      t.string :address, limit: 42, null: false, index: true
      t.text :data
      t.string :topic0, limit: 66, index: true
      t.string :topic1, limit: 66, index: true
      t.string :topic2, limit: 66, index: true
      t.string :topic3, limit: 66
      t.boolean :removed, default: false
      t.timestamps
    end
    add_index :logs, [:address, :topic0]
    add_index :logs, [:block_number, :transaction_index, :log_index], unique: true, name: 'unique_log_index'
    add_foreign_key :logs, :blocks, column: :block_number, primary_key: :number, on_delete: :cascade
    add_foreign_key :logs, :transactions, column: :transaction_hash, primary_key: :transaction_hash, on_delete: :cascade

    create_table :tokens, id: false, primary_key: :id do |t|
      t.bigint :id, null: false, auto_increment: true, primary_key: true
      t.string :address, limit: 42, null: false, index: { unique: true }
      t.string :token_type, null: false, index: true # ENUM simulation
      t.string :name
      t.string :symbol, limit: 50, index: true
      t.integer :decimals, limit: 1, unsigned: true
      t.string :total_supply, limit: 78
      t.bigint :first_seen_block
      t.bigint :holder_count, default: 0, unsigned: true
      t.bigint :transfer_count, default: 0, unsigned: true
      t.timestamps
    end

    create_table :token_transfers, id: false, primary_key: :id do |t|
      t.bigint :id, null: false, auto_increment: true, primary_key: true
      t.string :transaction_hash, limit: 66, null: false
      t.integer :log_index, null: false, unsigned: true
      t.bigint :block_number, null: false, index: true
      t.string :token_address, limit: 42, null: false, index: true
      t.string :token_type, null: false
      t.string :from_address, limit: 42, null: false, index: true
      t.string :to_address, limit: 42, null: false, index: true
      t.string :value, limit: 78
      t.string :token_id, limit: 78
      t.string :amount, limit: 78
      t.bigint :timestamp, null: false, index: true
      t.timestamps
    end
    add_index :token_transfers, [:token_address, :from_address]
    add_index :token_transfers, [:token_address, :to_address]
    add_index :token_transfers, [:transaction_hash, :log_index], unique: true, name: 'unique_transfer_index'
    add_foreign_key :token_transfers, :tokens, column: :token_address, primary_key: :address, on_delete: :cascade
    add_foreign_key :token_transfers, :transactions, column: :transaction_hash, primary_key: :transaction_hash, on_delete: :cascade
    add_foreign_key :token_transfers, :blocks, column: :block_number, primary_key: :number, on_delete: :cascade

    create_table :contracts, id: false, primary_key: :id do |t|
      t.bigint :id, null: false, auto_increment: true, primary_key: true
      t.string :address, limit: 42, null: false, index: { unique: true }
      t.string :creator_address, limit: 42, index: true
      t.string :creation_transaction_hash, limit: 66
      t.bigint :creation_block_number, index: true
      t.text :bytecode, limit: 4294967295 # LONGTEXT
      t.boolean :is_verified, default: false
      t.text :source_code, limit: 4294967295
      t.string :compiler_version, limit: 50
      t.boolean :optimization_enabled
      t.timestamps
    end
    add_foreign_key :contracts, :addresses, column: :creator_address, primary_key: :address
  end
end
