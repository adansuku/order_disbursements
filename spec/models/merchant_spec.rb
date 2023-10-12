require 'rails_helper'

RSpec.describe Merchant, type: :model do
  let!(:merchant) { create(:merchant) }
  describe '#validations' do
    it 'is valid with valid attributes' do
      expect(merchant).to be_valid
    end

    it 'is not valid without an email' do
      merchant.email = nil
      expect(merchant).not_to be_valid
      expect(merchant.errors[:email]).to include("can't be blank")
    end
  end

    it 'is not valid without a disbursement_frequency' do
      merchant.disbursement_frequency = nil
      expect(merchant).not_to be_valid
      expect(merchant.errors[:disbursement_frequency]).to include("can't be blank")
    end

    it 'is not valid without a minimum_monthly_fee' do
      merchant.minimum_monthly_fee = nil
      expect(merchant).not_to be_valid
      expect(merchant.errors[:minimum_monthly_fee]).to include("can't be blank")
    end

    it 'is not valid without a reference' do
      merchant.reference = nil
      expect(merchant).not_to be_valid
      expect(merchant.errors[:reference]).to include("can't be blank")
    end
  end

  describe '#pending_daily_orders_for_disbursement' do
    it 'returns orders that are pending for daily disbursement' do
      today_order = create(:order, merchant: merchant, created_at: Time.zone.now)
      yesterday_order = create(:order, merchant: merchant, created_at: Time.zone.now - 1.day)
      order_with_disbursement = create(:order, merchant: merchant, created_at: Time.zone.now - 1.day,
                                               disbursement: create(:disbursement))

      pending_orders = merchant.pending_daily_orders_for_disbursement

      expect(pending_orders.keys).to include(yesterday_order.created_at.to_date)
      expect(pending_orders.keys).not_to include(today_order.created_at.to_date)
      expect(pending_orders[yesterday_order.created_at.to_date]).to include(yesterday_order)
      expect(pending_orders[yesterday_order.created_at.to_date]).not_to include(order_with_disbursement)
    end
  end

  describe '#pending_weekly_orders_for_disbursement' do
    let(:live_on) { Date.today.beginning_of_month }
    let!(:order1) { create(:order, merchant: merchant, created_at: live_on, disbursement: nil) }
    let!(:order2) { create(:order, merchant: merchant, created_at: live_on + 7.days, disbursement: nil) }
    let!(:order3) { create(:order, merchant: merchant, created_at: live_on + 6.days, disbursement: nil) }

    it 'groups orders by week with pending disbursement, and not include and order from live_on day + 7 days' do
      merchant.update_attribute(:live_on, live_on)
      result = merchant.pending_weekly_orders_for_disbursement

      expect(result).to be_a(Hash)
      expect(result.keys).to include(live_on)
      expect(result[live_on].count).to eq(2)
    end

    it 'doesn´t return any order if the orders are older thank live_on date' do
      live_on = Date.today.next_month.beginning_of_month
      merchant.update_attribute(:live_on, live_on)
      result = merchant.pending_weekly_orders_for_disbursement

      expect(result).to eq({})
    end
  end
end
