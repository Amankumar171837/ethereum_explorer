class AddFieldCountryofResidenceToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :country_of_residence, :string, after: :country
  end
end
