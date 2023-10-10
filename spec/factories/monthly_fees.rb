FactoryBot.define do
  factory :monthly_fee do
    amount { Faker::Commerce.price(range: 10..100) }
    month { Faker::Date.between(from: 1.year.ago, to: Date.today) }

    association :merchant

    trait :invalid do
      merchant_id { nil }
      month { nil }
      amount { nil }
    end
  end
end
