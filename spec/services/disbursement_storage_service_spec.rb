RSpec.describe DisbursementStorageService, type: :service do
  let(:merchant) { create(:merchant) }
  let(:date) { Date.today }
  let(:orders) { create_list(:order, 3, merchant: merchant, created_at: date) }
  let(:service) { DisbursementStorageService.new(date, orders, merchant) }

  describe '#calculate_and_create_disbursement' do
    context 'when orders are present' do
      it 'calculates and creates a disbursement' do
        expect { service.calculate_and_create_disbursement }.to change { Disbursement.count }.by(1)
      end

      it 'updates orders with disbursement and commission_fee' do
        service.calculate_and_create_disbursement
        orders.each do |order|
          order.reload
          expect(order.disbursement).to be_present
          expect(order.commission_fee).to eq(order.commission)
        end
      end

      it 'rolls back the transaction on error' do
        disbusement = create(:disbursement)
        disbursement_count = Disbursement.count
        disbusement_orders = create_list(:order, 3, merchant: merchant, created_at: date, disbursement: disbusement)

        DisbursementStorageService.new(date, disbusement_orders, merchant).calculate_and_create_disbursement

        expect(Disbursement.count).to eq(disbursement_count)
      end
    end

    context 'when orders are empty' do
      it 'does not create a disbursement' do
        orders.clear
        expect { service.calculate_and_create_disbursement }.not_to change { Disbursement.count }
      end
    end
  end

  describe 'private methods' do
    describe '#first_order_of_month?' do
      it 'returns true for the first order of the month' do
        order = create(:order, merchant: merchant, created_at: date.beginning_of_month)
        expect(service.send(:first_order_of_month?, order)).to be true
      end

      it 'returns false for subsequent orders of the month' do
        order = create(:order, merchant: merchant, created_at: date.end_of_month)
        expect(service.send(:first_order_of_month?, order)).to be false
      end
    end

    describe '#generate_unique_reference' do
      it 'generates a unique reference based on merchant id and date' do
        reference = service.send(:generate_unique_reference)
        expect(reference).to match(/#{merchant.id}-\d{8}-[0-9a-f]{8}/)
      end
    end
  end
end
