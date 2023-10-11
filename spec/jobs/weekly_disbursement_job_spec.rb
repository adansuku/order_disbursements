require 'rails_helper'

RSpec.describe WeeklyDisbursementJob do
  describe '#perform' do
    it 'calculates and creates disbursements for merchants with weekly frequency' do
      weekly_disbursement_service = instance_double(WeeklyDisbursementService)

      expect(weekly_disbursement_service).to receive(:perform)

      allow(WeeklyDisbursementService).to receive(:new).and_return(weekly_disbursement_service)

      WeeklyDisbursementJob.new.perform
    end

    it 'doesn´t calculates and creates disbursements for merchants with weekly frequency' do
      weekly_disbursement_service = instance_double(WeeklyDisbursementService)

      allow(weekly_disbursement_service).to receive(:perform).and_raise(StandardError, 'Simulated error')
      allow(WeeklyDisbursementService).to receive(:new).and_return(weekly_disbursement_service)

      expect { WeeklyDisbursementService.new.perform }.to raise_error(StandardError, 'Simulated error')
    end
  end
end
