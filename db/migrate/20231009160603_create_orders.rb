class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :merchant, null: false, foreign_key: true
      t.references :orders, :disbursement, foreign_key: true

      t.float :amount

      t.timestamps
    end
  end
end
