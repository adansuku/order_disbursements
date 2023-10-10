FactoryBot.define do
  factory :order do
    sequence(:amount) { |n| Faker::Commerce.price(range: 10..100) + n }
    created_at { Time.current - rand(1..30).days }

    association :merchant

    trait :with_disbursement do
      association :disbursement
    end
  end
end
