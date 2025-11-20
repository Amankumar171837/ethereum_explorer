class CreateEmailType < ActiveRecord::Migration[5.2]
  def change
    create_table :email_types do |t|
      t.string :name,       null: false, index: { unique: true }
      t.string :description
      t.string :status,     null: false

      t.timestamps
    end
  end
end
