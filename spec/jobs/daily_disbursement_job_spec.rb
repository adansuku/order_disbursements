require 'rails_helper'

RSpec.describe DailyDisbursementJob do
  describe '#perform' do
    it 'calculates and creates disbursements for merchants with daily frequency' do
      daily_disbursement_service = instance_double(DailyDisbursementService)

      expect(daily_disbursement_service).to receive(:perform)

      allow(DailyDisbursementService).to receive(:new).and_return(daily_disbursement_service)

      DailyDisbursementJob.new.perform
    end

    it 'doesn´t calculates and creates disbursements for merchants with daily frequency' do
      daily_disbursement_service = instance_double(DailyDisbursementService)

      allow(daily_disbursement_service).to receive(:perform).and_raise(StandardError, 'Simulated error')
      allow(DailyDisbursementService).to receive(:new).and_return(daily_disbursement_service)

      expect { DailyDisbursementJob.new.perform }.to raise_error(StandardError, 'Simulated error')
    end
  end
end
