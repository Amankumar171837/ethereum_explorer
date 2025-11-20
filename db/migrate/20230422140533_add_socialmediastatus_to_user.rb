class AddSocialmediastatusToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :social_media_status, :string, default: 'active', after: :password_reset_at
  end
end
