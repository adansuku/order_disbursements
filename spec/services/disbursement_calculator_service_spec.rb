require 'rails_helper'

RSpec.describe DisbursementCalculatorService, type: :service do
  let(:merchant) { create(:merchant) }
  let(:service) { DisbursementCalculatorService.new(merchant) }

  describe '#calculate_and_create_disbursements' do
    context 'when disbursement frequency is DAILY' do
      it 'calls daily_disbursement method' do
        allow(service).to receive(:daily_disbursement)
        allow(service).to receive(:weekly_disbursement)

        service.calculate_and_create_disbursements

        expect(service).to have_received(:daily_disbursement)
        expect(service).not_to have_received(:weekly_disbursement)
      end
    end

    context 'when disbursement frequency is WEEKLY' do
      it 'calls weekly_disbursement method' do
        merchant.update(disbursement_frequency: 'WEEKLY')

        allow(service).to receive(:daily_disbursement)
        allow(service).to receive(:weekly_disbursement)

        service.calculate_and_create_disbursements

        expect(service).to have_received(:weekly_disbursement)
        expect(service).not_to have_received(:daily_disbursement)
      end
    end
  end
end
