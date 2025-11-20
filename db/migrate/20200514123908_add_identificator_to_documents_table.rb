class AddIdentificatorToDocumentsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :applicant_id, :string, after: :user_id
  end
end
