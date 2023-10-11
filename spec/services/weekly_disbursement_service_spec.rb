require 'rails_helper'

RSpec.describe WeeklyDisbursementService do
  describe '#perform' do
    it 'enqueues disbursement jobs for merchants with weekly frequency' do
      merchant = create(:merchant, disbursement_frequency: 'WEEKLY')
      allow(Merchant).to receive(:where).with(disbursement_frequency: 'WEEKLY').and_return([merchant])

      expect(DisbursementWorker).to receive(:perform_async).with(merchant.id)

      WeeklyDisbursementService.new.perform
    end
  end
end
