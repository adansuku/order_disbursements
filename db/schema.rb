# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2023_10_10_122502) do
  create_table "disbursements", charset: "utf8mb4", force: :cascade do |t|
    t.string "reference"
    t.date "disbursed_at"
    t.bigint "merchant_id", null: false
    t.decimal "amount_disbursed", precision: 10, scale: 2
    t.decimal "amount_fees", precision: 10, scale: 2
    t.decimal "total_order_amount", precision: 10, scale: 2
    t.string "disbursement_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_disbursements_on_merchant_id"
  end

  create_table "merchants", charset: "utf8mb4", force: :cascade do |t|
    t.string "reference"
    t.string "email"
    t.date "live_on"
    t.string "disbursement_frequency"
    t.float "minimum_monthly_fee"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "monthly_fees", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "merchant_id", null: false
    t.date "month"
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_monthly_fees_on_merchant_id"
  end

  create_table "orders", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "merchant_id", null: false
    t.bigint "disbursement_id"
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "commission_fee", precision: 10, scale: 2
    t.index ["amount"], name: "index_orders_on_amount"
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["disbursement_id"], name: "index_orders_on_disbursement"
    t.index ["disbursement_id"], name: "index_orders_on_disbursement_id"
    t.index ["merchant_id"], name: "index_orders_on_merchant_id"
  end

  add_foreign_key "disbursements", "merchants"
  add_foreign_key "monthly_fees", "merchants"
  add_foreign_key "orders", "disbursements"
  add_foreign_key "orders", "merchants"
end
