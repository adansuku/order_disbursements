require 'rails_helper'

RSpec.describe MonthlyDisbursementService do
  describe '#perform' do
    it 'calls calculate_and_create_monthly_fee with the beginning of the month' do
      date = Date.new(2023, 10, 1)
      merchant = create(:merchant)

      expect_any_instance_of(DisbursementCalculatorService).to receive(:calculate_and_create_monthly_fee).with(date.beginning_of_month)
      MonthlyDisbursementService.new(date, merchant).perform
    end
  end

  describe '#all_months' do
    it 'calls create_monthly_fees_up_to_current_month for the specified merchant' do
      merchant = create(:merchant)

      expect_any_instance_of(DisbursementCalculatorService).to receive(:create_monthly_fees_up_to_current_month)
      MonthlyDisbursementService.new(merchant).all_months
    end
  end
end
