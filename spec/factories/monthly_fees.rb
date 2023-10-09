FactoryBot.define do
  factory :monthly_fee do
    amount { association(:merchant, :with_minimum_monthly_fee).minimum_monthly_fee }

    association :merchant
  end
end
