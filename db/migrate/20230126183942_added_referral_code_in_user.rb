class AddedReferralCodeInUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :referral_code, :string, limit: 255, after: :referral_id

    # Assign referral code to the existing users.
    User.all.each do |u|
      u.update(referral_code: SecureRandom.alphanumeric(8))
    end

    add_index :users, :referral_code, unique: true
  end
end
