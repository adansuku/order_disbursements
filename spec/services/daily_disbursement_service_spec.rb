require 'rails_helper'

RSpec.describe DailyDisbursementService do
  describe '#perform' do
    let(:merchant) { create(:merchant) }

    it 'calculates and creates disbursements for merchants with daily frequency' do
      merchant = create(:merchant, disbursement_frequency: 'DAILY')
      allow(Merchant).to receive(:where).with(disbursement_frequency: 'DAILY').and_return([merchant])

      expect(DisbursementWorker).to receive(:perform_async).with(merchant.id)

      DailyDisbursementService.new.perform
    end
  end
end
