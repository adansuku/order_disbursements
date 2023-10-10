class ChangeColumnTypeFromFloatToDecimal < ActiveRecord::Migration[7.1]
  def change
    change_column :orders, :amount, :decimal, precision: 10, scale: 2
    change_column :monthly_fees, :amount, :decimal, precision: 10, scale: 2
    change_column :disbursements, :amount_disbursed, :decimal, precision: 10, scale: 2
    change_column :disbursements, :amount_fees, :decimal, precision: 10, scale: 2
    change_column :disbursements, :total_order_amount, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :orders, :amount, :float
    change_column :monthly_fees, :amount, :float
    change_column :disbursements, :amount_disbursed, :float
    change_column :disbursements, :amount_fees, :float
    change_column :disbursements, :total_order_amount, :float
  end
end
