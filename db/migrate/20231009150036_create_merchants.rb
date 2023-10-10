class CreateMerchants < ActiveRecord::Migration[7.1]
  def up
    create_table :merchants do |t|
      t.string :reference
      t.string :email
      t.date :live_on
      t.string :disbursement_frequency
      t.float :minimum_monthly_fee

      t.timestamps
    end
  end

  def down
    drop_table :merchants
  end
end
