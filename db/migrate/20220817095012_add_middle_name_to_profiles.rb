class AddMiddleNameToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :middle_name_encrypted, :string, limit: 1024, after: :last_name_encrypted
  end
end
