require 'rails_helper'

RSpec.describe Merchant, type: :model do
  let!(:merchant) { create(:merchant) }
  let!(:disbursement) { create(:disbursement, merchant: merchant) }
  let!(:order) { create(:order, merchant: merchant, disbursement: disbursement) }
  let!(:monthly_fee) { create(:monthly_fee, merchant: merchant) }

  describe 'should check associations for the merchant ' do
    it 'should return the merchant asociations' do
      expect(merchant.reload.orders).not_to be_empty
      expect(merchant.disbursements.reload).not_to be_empty
      expect(merchant.monthly_fees.reload).not_to be_empty
    end

    it 'destroys associated orders, disbursements, and monthly_fees' do
      merchant.destroy

      expect(merchant.orders.reload).to be_empty
      expect(merchant.disbursements.reload).to be_empty
      expect(merchant.monthly_fees.reload).to be_empty
    end
  end
end
