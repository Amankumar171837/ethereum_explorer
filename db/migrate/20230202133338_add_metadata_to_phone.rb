class AddMetadataToPhone < ActiveRecord::Migration[5.2]
  def change
    add_column :phones, :metadata, :json, after: :validated_at
  end
end
