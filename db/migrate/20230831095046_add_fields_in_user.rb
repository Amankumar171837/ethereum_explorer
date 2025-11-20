class AddFieldsInUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :badge, :string, after: :state
    add_column :users, :login_metadata, :json, after: :social_media_status
    add_column :users, :general_info, :text, after: :login_metadata
  end
end
