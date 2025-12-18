class AddApplicantIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :applicant_id, :string, after: :level
  end
end
