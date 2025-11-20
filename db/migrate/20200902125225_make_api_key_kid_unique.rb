class MakeApiKeyKidUnique < ActiveRecord::Migration[5.2]
  def up
    add_index :apikeys, :kid, unique: true unless index_exists?(:apikeys, :kid)
  end

  def down
    remove_index :apikeys, :kid if index_exists?(:apikeys, :kid)
  end
end
