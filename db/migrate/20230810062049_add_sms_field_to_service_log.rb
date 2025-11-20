class AddSmsFieldToServiceLog < ActiveRecord::Migration[5.2]
  def up
    add_column :service_logs, :sms_id, :string, after: :user_country
    add_column :service_logs, :phone_number, :string, index: true, after: :user_country

    ServiceLog.where.not(metadata: nil).each do |service_log|
      phone_number = service_log.metadata['phone_number']
      service_log.update(phone_number: phone_number) if phone_number.present?
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
