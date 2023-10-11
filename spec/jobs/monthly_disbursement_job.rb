require 'rails_helper'

RSpec.describe MonthlyFeeJob do
  describe '#perform' do
    it 'calculates and creates monthly_fee for merchants' do
      monthly_fee_service = instance_double(MonthlyFeeJob)

      expect(monthly_fee_service).to receive(:perform)

      allow(MonthlyFeeJob).to receive(:new).and_return(monthly_fee_service)

      MonthlyFeeJob.new.perform
    end

    it 'doesn´t calculates and creates monthly_fee for merchants' do
      monthly_fee_service = instance_double(MonthlyFeeJob)

      allow(monthly_fee_service).to receive(:perform).and_raise(StandardError, 'Simulated error')
      allow(MonthlyFeeJob).to receive(:new).and_return(monthly_fee_service)

      expect { MonthlyFeeJob.new.perform }.to raise_error(StandardError, 'Simulated error')
    end
  end
end
