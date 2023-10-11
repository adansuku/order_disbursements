require 'rails_helper'

RSpec.describe MonthlyFeeService do
  let(:merchant) { create(:merchant) }
  let(:service) { MonthlyFeeService.new(merchant) }

  describe '#perform' do
    it 'calls calculate_and_create_monthly_fee with the beginning of the month' do
      date = Date.new(2023, 10, 1)
      merchant = create(:merchant)

      expect_any_instance_of(MonthlyFeeService).to receive(:calculate_and_create_monthly_fee).with(date.beginning_of_month)
      MonthlyFeeService.new(merchant, date).perform
    end
  end

  describe '#all_months' do
    it 'calls create_monthly_fees_up_to_current_month for the specified merchant' do
      merchant = create(:merchant)

      expect_any_instance_of(MonthlyFeeService).to receive(:create_monthly_fees_up_to_current_month)
      MonthlyFeeService.new(merchant).all_months
    end
  end

  describe '#calculate_and_create_monthly_fee' do

    let(:merchant) { create(:merchant, minimum_monthly_fee: 10) }
    let(:order) { create(:order, merchant: merchant, created_at: Time.now.last_month, amount: 20) }

    it 'creates a monthly fee with the correct amount' do
      merchant.minimum_monthly_fee = 20
      allow_any_instance_of(MonthlyFeeService).to receive(:calculate_monthly_fee).and_return(10)

      date = Time.current
      MonthlyFeeService.new(merchant, date).perform

      monthly_fee = MonthlyFee.last
      expect(monthly_fee.amount).to eq(10)
    end

    it 'does not create a new monthly fee if already exists for the month' do
      date = Date.new(2022 - 2 - 2).beginning_of_month
      create(:monthly_fee, merchant: merchant, month: date.next_month.beginning_of_month)

      expect { MonthlyFeeService.new(merchant, date).perform }.not_to change(MonthlyFee, :count)
    end

    it 'calculates and creates monthly fee correctly' do
      date = Time.current.beginning_of_month

      allow(merchant.orders).to receive(:where).and_return([order])
      MonthlyFeeService.new(merchant, date).perform
      monthly_fee = MonthlyFee.find_by(merchant_id: merchant.id, month: date.next_month.beginning_of_month)

      # The order last month included one order with amount = 20 so amount < 50 and the commision is 1%
      # total_monthly_fee = 0,20
      # chargeable_amount is minumum_monthly_fee - total_monthly_fee
      # if the total_monthly_fee < minumum_monthly_fee
      # Should be 9.8 for this reason
      expect(monthly_fee).not_to be_nil
      expect(monthly_fee.amount).to eq(9.8)
    end
  end
end
