class CreateMonthlyFees < ActiveRecord::Migration[7.1]
  def up
    create_table :monthly_fees do |t|
      t.references :merchant, null: false, foreign_key: true
      t.date :month
      t.float :amount

      t.timestamps
    end
  end

  def down
    drop_table :monthly_fees
  end
end
