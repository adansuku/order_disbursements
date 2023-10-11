require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe DisbursementWorker, type: :worker do
  # Neccesary Sidekiq to use the in-memory mode during tests
  before { Sidekiq::Testing.inline! }

  describe '#perform' do
    it 'calculates and creates disbursements for the specified merchant' do
      merchant = create(:merchant)
      expect_any_instance_of(DisbursementCalculatorService).to receive(:calculate_and_create_disbursements)

      DisbursementWorker.new.perform(merchant.id)
    end

    it 'handles the case when the specified merchant does not exist' do
      non_existent_merchant_id = 'not a merchant'
      allow(Merchant).to receive(:find).with(non_existent_merchant_id).and_raise(ActiveRecord::RecordNotFound)

      expect { DisbursementWorker.new.perform(non_existent_merchant_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
