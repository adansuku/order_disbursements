FactoryBot.define do
  factory :order do
    amount { Faker::Commerce.price(range: 10..100) }
    created_at { Time.current - rand(1..30).days }

    association :merchant
  end
end
