class AddPasswordUpdatedAtToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :password_reset_at, :datetime, default: '1947-02-02 00:00:00', after: :agreement_time
  end
end
