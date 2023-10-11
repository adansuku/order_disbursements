require 'rails_helper'

RSpec.describe YearlyExportJob do
  describe '#perform' do
    it 'calculates and creates disbursements report for merchants with yearly frequency' do
      yearly_disbursement_service = instance_double(YearlyDisbursementService)

      expect(yearly_disbursement_service).to receive(:perform)

      allow(YearlyExportJob).to receive(:new).and_return(yearly_disbursement_service)

      YearlyExportJob.new.perform
    end

    it 'doesn´t calculates and creates disbursements report for merchants with yearly frequency' do
      yearly_disbursement_service = instance_double(YearlyDisbursementService)

      allow(yearly_disbursement_service).to receive(:perform).and_raise(StandardError, 'Simulated error')
      allow(YearlyDisbursementService).to receive(:new).and_return(yearly_disbursement_service)

      expect { YearlyDisbursementService.new.perform }.to raise_error(StandardError, 'Simulated error')
    end
  end
end
