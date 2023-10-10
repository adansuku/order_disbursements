require 'rails_helper'

RSpec.describe MonthlyFee, type: :model do
  let(:merchant) { create(:merchant) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      monthly_fee = build(:monthly_fee, merchant: merchant)
      expect(monthly_fee).to be_valid
    end

    it 'is not valid without merchant_id' do
      monthly_fee = build(:monthly_fee, merchant: nil)
      expect(monthly_fee).not_to be_valid
    end

    it 'is not valid without month' do
      monthly_fee = build(:monthly_fee, merchant: merchant, month: nil)
      expect(monthly_fee).not_to be_valid
    end

    it 'is not valid without amount' do
      monthly_fee = build(:monthly_fee, merchant: merchant, amount: nil)
      expect(monthly_fee).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a merchant' do
      monthly_fee = create(:monthly_fee, merchant: merchant)
      expect(monthly_fee.merchant).to eq(merchant)
    end
  end

  describe 'monthly_disbursement_report', :focus do
    it 'returns the monthly disbursement report' do
      merchant.monthly_fees.destroy_all

      create(:monthly_fee, merchant: merchant, month: Time.current.beginning_of_month.advance(years: -1))
      create(:monthly_fee, merchant: merchant, month: 1.month.ago.beginning_of_month)
      merchant.monthly_fees.reload

      report = MonthlyFee.monthly_disbursement_report
      expect(report).to be_an(Array)
      expect(report.length).to eq(2)

      expect(report[0][:year]).to eq(Time.current.year - 1)
      expect(report[0][:total_amount_monthly_fees]).to be_a(Float)

      expect(report[1][:year]).to eq(1.month.ago.year)
      expect(report[1][:total_amount_monthly_fees]).to be_a(Float)
    end
  end
end
