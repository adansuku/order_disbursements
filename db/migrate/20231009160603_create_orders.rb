class CreateOrders < ActiveRecord::Migration[7.1]
  def up
    create_table :orders do |t|
      t.references :merchant, null: false, foreign_key: true
      t.references :disbursement, foreign_key: true
      t.float :amount
      t.timestamps
    end
  end

  def down
    drop_table :orders
  end
end
