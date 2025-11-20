class AddIndexInUser < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :username, unique: true
    add_index :users, :phone_number
    add_index :users, :platform
    add_index :users, :state
  end
end
