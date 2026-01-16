# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_01_16_103517) do
  create_table "addresses", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "address", limit: 42, null: false
    t.boolean "is_contract", default: false
    t.string "balance", limit: 78, default: "0"
    t.datetime "balance_updated_at"
    t.bigint "transaction_count", default: 0, unsigned: true
    t.bigint "first_seen_block"
    t.bigint "last_seen_block"
    t.string "contract_creator", limit: 42
    t.string "contract_creation_tx", limit: 66
    t.bigint "contract_creation_block"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_addresses_on_address", unique: true
    t.index ["first_seen_block"], name: "index_addresses_on_first_seen_block"
    t.index ["is_contract"], name: "index_addresses_on_is_contract"
  end

  create_table "blocks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "number", null: false
    t.string "block_hash", limit: 66, null: false
    t.string "parent_hash", limit: 66, null: false
    t.bigint "timestamp", null: false
    t.string "miner", limit: 42, null: false
    t.string "difficulty", limit: 78
    t.string "total_difficulty", limit: 78
    t.bigint "size"
    t.bigint "gas_used"
    t.bigint "gas_limit"
    t.bigint "base_fee_per_gas"
    t.string "transactions_root", limit: 66
    t.string "state_root", limit: 66
    t.string "receipts_root", limit: 66
    t.text "extra_data", size: :medium
    t.string "nonce", limit: 18
    t.integer "transaction_count", default: 0, unsigned: true
    t.datetime "indexed_at", null: false
    t.boolean "is_canonical", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["block_hash"], name: "index_blocks_on_block_hash", unique: true
    t.index ["is_canonical", "number"], name: "index_blocks_on_is_canonical_and_number"
    t.index ["miner"], name: "index_blocks_on_miner"
    t.index ["number"], name: "index_blocks_on_number", unique: true
    t.index ["timestamp"], name: "index_blocks_on_timestamp"
  end

  create_table "contracts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "address", limit: 42, null: false
    t.string "creator_address", limit: 42
    t.string "creation_transaction_hash", limit: 66
    t.bigint "creation_block_number"
    t.text "bytecode", size: :long
    t.boolean "is_verified", default: false
    t.text "source_code", size: :long
    t.string "compiler_version", limit: 50
    t.boolean "optimization_enabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_contracts_on_address", unique: true
    t.index ["creation_block_number"], name: "index_contracts_on_creation_block_number"
    t.index ["creator_address"], name: "index_contracts_on_creator_address"
  end

  create_table "logs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "block_number", null: false
    t.string "block_hash", limit: 66, null: false
    t.string "transaction_hash", limit: 66, null: false
    t.integer "transaction_index", null: false, unsigned: true
    t.integer "log_index", null: false, unsigned: true
    t.string "address", limit: 42, null: false
    t.text "data", size: :long
    t.string "topic0", limit: 66
    t.string "topic1", limit: 66
    t.string "topic2", limit: 66
    t.string "topic3", limit: 66
    t.boolean "removed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address", "topic0"], name: "index_logs_on_address_and_topic0"
    t.index ["address"], name: "index_logs_on_address"
    t.index ["block_number", "transaction_index", "log_index"], name: "unique_log_index", unique: true
    t.index ["block_number"], name: "index_logs_on_block_number"
    t.index ["topic0"], name: "index_logs_on_topic0"
    t.index ["topic1"], name: "index_logs_on_topic1"
    t.index ["topic2"], name: "index_logs_on_topic2"
    t.index ["transaction_hash"], name: "index_logs_on_transaction_hash"
  end

  create_table "token_transfers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "transaction_hash", limit: 66, null: false
    t.integer "log_index", null: false, unsigned: true
    t.bigint "block_number", null: false
    t.string "token_address", limit: 42, null: false
    t.string "token_type", null: false
    t.string "from_address", limit: 42, null: false
    t.string "to_address", limit: 42, null: false
    t.string "value", limit: 78
    t.string "token_id", limit: 78
    t.string "amount", limit: 78
    t.bigint "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["block_number"], name: "index_token_transfers_on_block_number"
    t.index ["from_address"], name: "index_token_transfers_on_from_address"
    t.index ["timestamp"], name: "index_token_transfers_on_timestamp"
    t.index ["to_address"], name: "index_token_transfers_on_to_address"
    t.index ["token_address", "from_address"], name: "index_token_transfers_on_token_address_and_from_address"
    t.index ["token_address", "to_address"], name: "index_token_transfers_on_token_address_and_to_address"
    t.index ["token_address"], name: "index_token_transfers_on_token_address"
    t.index ["transaction_hash", "log_index"], name: "unique_transfer_index", unique: true
  end

  create_table "tokens", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "address", limit: 42, null: false
    t.string "token_type", null: false
    t.string "name"
    t.string "symbol", limit: 50
    t.integer "decimals", limit: 1, unsigned: true
    t.string "total_supply", limit: 78
    t.bigint "first_seen_block"
    t.bigint "holder_count", default: 0, unsigned: true
    t.bigint "transfer_count", default: 0, unsigned: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_tokens_on_address", unique: true
    t.index ["symbol"], name: "index_tokens_on_symbol"
    t.index ["token_type"], name: "index_tokens_on_token_type"
  end

  create_table "transactions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "transaction_hash", limit: 66, null: false
    t.bigint "block_number", null: false
    t.string "block_hash", limit: 66, null: false
    t.integer "transaction_index", null: false, unsigned: true
    t.string "from_address", limit: 42, null: false
    t.string "to_address", limit: 42
    t.string "value", limit: 78, default: "0", null: false
    t.bigint "gas", null: false
    t.bigint "gas_price"
    t.bigint "max_fee_per_gas"
    t.bigint "max_priority_fee_per_gas"
    t.text "input", size: :long
    t.bigint "nonce", null: false
    t.integer "status", limit: 1, unsigned: true
    t.bigint "gas_used"
    t.bigint "cumulative_gas_used"
    t.bigint "effective_gas_price"
    t.string "contract_address", limit: 42
    t.integer "transaction_type", limit: 1, default: 0, unsigned: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["block_number", "transaction_index"], name: "index_transactions_on_block_number_and_transaction_index"
    t.index ["block_number"], name: "index_transactions_on_block_number"
    t.index ["contract_address"], name: "index_transactions_on_contract_address"
    t.index ["from_address"], name: "index_transactions_on_from_address"
    t.index ["to_address"], name: "index_transactions_on_to_address"
    t.index ["transaction_hash"], name: "index_transactions_on_transaction_hash", unique: true
  end

  add_foreign_key "contracts", "addresses", column: "creator_address", primary_key: "address"
  add_foreign_key "logs", "blocks", column: "block_number", primary_key: "number", on_delete: :cascade
  add_foreign_key "logs", "transactions", column: "transaction_hash", primary_key: "transaction_hash", on_delete: :cascade
  add_foreign_key "token_transfers", "blocks", column: "block_number", primary_key: "number", on_delete: :cascade
  add_foreign_key "token_transfers", "tokens", column: "token_address", primary_key: "address", on_delete: :cascade
  add_foreign_key "token_transfers", "transactions", column: "transaction_hash", primary_key: "transaction_hash", on_delete: :cascade
  add_foreign_key "transactions", "blocks", column: "block_number", primary_key: "number", on_delete: :cascade
end
