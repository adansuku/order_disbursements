class AddIndexesToOrders < ActiveRecord::Migration[7.1]
  def up
    add_index :orders, :created_at, name: 'index_orders_on_created_at'
    add_index :orders, :disbursement_id, name: 'index_orders_on_disbursement'
    add_index :orders, :amount, name: 'index_orders_on_amount'
  end

  def down
    remove_index :orders, name: 'index_orders_on_created_at'
    remove_index :orders, name: 'index_orders_on_disbursement'
    remove_index :orders, name: 'index_orders_on_amount'
  end
end
