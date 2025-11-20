class AddStatusUpdatedAtToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :status_updated_at, :datetime, default: '1947-02-02 00:00:00', after: :social_media_status
  end
end
