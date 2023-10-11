require 'rails_helper'

RSpec.describe DisbursementCalculatorService, type: :service do
  let(:merchant) { create(:merchant) }
  let(:service) { DisbursementCalculatorService.new(merchant) }

  describe '#calculate_and_create_disbursements' do
    context 'when disbursement frequency is DAILY' do
      it 'calls daily_disbursement method' do
        allow(service).to receive(:daily_disbursement)
        allow(service).to receive(:weekly_disbursement)

        service.calculate_and_create_disbursements

        expect(service).to have_received(:daily_disbursement)
        expect(service).not_to have_received(:weekly_disbursement)
      end
    end

    context 'when disbursement frequency is WEEKLY' do
      it 'calls weekly_disbursement method' do
        merchant.update(disbursement_frequency: 'WEEKLY')

        allow(service).to receive(:daily_disbursement)
        allow(service).to receive(:weekly_disbursement)

        service.calculate_and_create_disbursements

        expect(service).to have_received(:weekly_disbursement)
        expect(service).not_to have_received(:daily_disbursement)
      end
    end
  end

  describe '#calculate_and_create_monthly_fee' do
    it 'creates a monthly fee with the correct amount' do
      merchant.minimum_monthly_fee = 20
      allow(service).to receive(:calculate_monthly_fee).and_return(10) # Adjust as needed

      date = Time.current.beginning_of_month
      service.calculate_and_create_monthly_fee(date)

      monthly_fee = MonthlyFee.last
      expect(monthly_fee.amount).to eq(10)
    end

    it 'does not create a new monthly fee if already exists for the month' do
      date = Date.new(2022 - 2 - 2).beginning_of_month
      create(:monthly_fee, merchant: merchant, month: date.next_month.beginning_of_month)

      expect { service.calculate_and_create_monthly_fee(date) }.not_to change(MonthlyFee, :count)
    end
  end

  describe '#create_monthly_fees_up_to_current_month' do
    let(:merchant) { create(:merchant, live_on: Time.now - 2.months) }
    let(:service) { DisbursementCalculatorService.new(merchant) }
    let(:order) { create(:order, merchant: merchant, created_at: Time.now.last_month) }

    it 'calls calculate_and_create_monthly_fee for each relevant month' do
      allow(service).to receive(:calculate_and_create_monthly_fee).and_return(true)
      service.create_monthly_fees_up_to_current_month

      expect(service).to have_received(:calculate_and_create_monthly_fee).at_least(:once)
    end
  end

  describe '#calculate_and_create_monthly_fee' do
    let(:merchant) { create(:merchant, minimum_monthly_fee: 10) }
    let(:order) { create(:order, merchant: merchant, created_at: Time.now.last_month, amount: 20) }
    let(:service) { DisbursementCalculatorService.new(merchant) }
    it 'calculates and creates monthly fee correctly' do
      date = Time.current.beginning_of_month

      allow(merchant.orders).to receive(:where).and_return([order])
      service.calculate_and_create_monthly_fee(date)
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
