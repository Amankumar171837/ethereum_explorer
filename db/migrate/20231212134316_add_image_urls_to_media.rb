class AddImageUrlsToMedia < ActiveRecord::Migration[5.2]
  def change
    add_column :media, :image_urls, :json, after: :upload
  end
end
