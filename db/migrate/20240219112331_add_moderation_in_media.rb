class AddModerationInMedia < ActiveRecord::Migration[5.2]
  def change
    add_column :media, :moderation_score, :string, after: :upload
    add_column :media, :moderation_metadata, :text, after: :moderation_score
  end
end
