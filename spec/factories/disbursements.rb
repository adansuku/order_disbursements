FactoryBot.define do
  factory :disbursement do
    reference { SecureRandom.hex(4) }
    disbursed_at { Time.current.beginning_of_day }
    amount_disbursed { 100.0 }
    amount_fees { 5.0 }
    total_order_amount { 105.0 }
    disbursement_type { 'DAILY' }

    association :merchant
  end
end
