FactoryBot.define do
  factory :merchant do
    email { Faker::Internet.email }
    live_on { Time.current.beginning_of_month }
    disbursement_frequency { 'DAILY' }
    minimum_monthly_fee { 15.0 }

    factory :merchant_with_orders do
      transient do
        orders_count { 5 }
      end

      after(:create) do |merchant, evaluator|
        create_list(:order, evaluator.orders_count, merchant: merchant)
      end
    end

    trait :weekly_disbursement do
      disbursement_frequency { 'WEEKLY' }
    end

    trait :with_minimum_monthly_fee do
      minimum_monthly_fee { 15.0 }
    end
  end
end
