require 'rails_helper'

RSpec.describe DailyDisbursementService do
  describe '#perform' do
    it 'calculates and creates disbursements for merchants with daily frequency' do
      allow(Merchant).to receive(:where).with(disbursement_frequency: 'DAILY').and_return([create(:merchant, disbursement_frequency: 'DAILY')])
      expect_any_instance_of(DisbursementCalculatorService).to receive(:calculate_and_create_disbursements)

      DailyDisbursementService.new.perform
    end
  end
end
