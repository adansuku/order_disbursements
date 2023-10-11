class Order < ApplicationRecord
  belongs_to :merchant
  belongs_to :disbursement, optional: true, dependent: :destroy

  validates :amount, presence: true
  validates :merchant_id, presence: true

  scope :unprocessed, -> { where(disbursement: nil) }

  COMMISSION_RATES = {
    high_rate: 0.01,
    middle_rate: 0.0095,
    low_rate: 0.0085
  }.freeze

  def commission
    if amount < 50
      amount * COMMISSION_RATES[:high_rate]
    elsif amount >= 50 && amount <= 300
      amount * COMMISSION_RATES[:middle_rate]
    else
      amount * COMMISSION_RATES[:low_rate]
    end.round(2)
  end

  def first_order_of_month?
    start_of_month = created_at.beginning_of_month
    !merchant.orders.exists?(['created_at >= ? AND created_at < ?', start_of_month, created_at])
  end
end
