class AddTypeToMedia < ActiveRecord::Migration[5.2]
  def change
    add_column :media, :type, :string, after: :image_urls
  end
end
