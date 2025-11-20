class CreateNotification < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci' do |t|
      t.string     :title
      t.text       :body
      t.json       :metadata

      t.timestamps
    end
  end
end
