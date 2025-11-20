class AddCounterCacheReferralInUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :users_count, :integer, null: false, default: 0, after: :platform
  end
end
