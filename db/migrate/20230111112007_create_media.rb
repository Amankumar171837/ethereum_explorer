class CreateMedia < ActiveRecord::Migration[5.2]
  def change
    create_table :media do |t|
      t.bigint :user_id, null: false, unsigned: true
      t.string :upload
      t.string :moderation_score
      t.text   :moderation_metadata
      t.json :image_urls
      t.string :type
      t.string :moderation_score
      t.text :moderation_metadata
      t.string :state

      t.timestamps
    end
  end
end
