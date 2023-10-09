# spec/models/order_spec.rb

require 'rails_helper'

RSpec.describe Order, type: :model do
  describe '#commission' do
    let(:merchant) { create(:merchant) }

    context 'when amount is less than 50' do
      it 'returns commission as 1% of the amount' do
        order = build(:order, merchant: merchant, amount: 40)
        expect(order.commission).to eq(0.4)
      end
    end

    context 'when amount is between 50 and 300' do
      it 'returns commission as 0.95% of the amount' do
        order = build(:order, merchant: merchant, amount: 150)
        expect(order.commission).to eq(1.43)
      end
    end

    context 'when amount is greater than 300' do
      it 'returns commission as 0.85% of the amount' do
        order = build(:order, merchant: merchant, amount: 400)
        expect(order.commission).to eq(3.4)
      end
    end
  end
end
