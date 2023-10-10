class AddCommissionFieldToOrders < ActiveRecord::Migration[7.1]
  def up
    add_column :orders, :commission_fee, :decimal, precision: 10, scale: 2
  end

  def down
    remove_column :orders, :commission_fee
  end
end
