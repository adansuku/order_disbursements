class CreateDisbursements < ActiveRecord::Migration[7.1]
  def change
    create_table :disbursements do |t|
      t.string :reference
      t.date :disbursed_at
      t.references :merchant, null: false, foreign_key: true
      t.float :amount_disbursed
      t.float :amount_fees
      t.float :total_order_amount
      t.string :disbursement_type

      t.timestamps
    end
  end
end
