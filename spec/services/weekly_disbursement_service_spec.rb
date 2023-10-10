require 'rails_helper'

RSpec.describe WeeklyDisbursementService do
  describe '#perform' do
    it 'calculates and creates disbursements for merchants with weekly frequency' do
      merchant = create(:merchant, disbursement_frequency: 'WEEKLY')

      allow(Merchant).to receive(:where).with(disbursement_frequency: 'WEEKLY').and_return([merchant])

      expect_any_instance_of(DisbursementCalculatorService).to receive(:calculate_and_create_disbursements)

      WeeklyDisbursementService.new.perform
    end
  end
end
