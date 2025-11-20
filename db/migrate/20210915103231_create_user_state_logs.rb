class CreateUserStateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :user_state_logs do |t|
      t.bigint :user_id, null: false, unsigned: true
      t.bigint :admin_id, null: false
      t.string :past_state, null: false
      t.string :state, null: false
      t.string :remark, null: false

      t.timestamps
      t.index :user_id
    end
  end
end
