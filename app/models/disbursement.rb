class Disbursement < ApplicationRecord
  belongs_to :merchant
  has_many :orders, dependent: :nullify

  validates_presence_of :reference, :disbursed_at, :merchant_id, :amount_disbursed, :amount_fees, :total_order_amount,
                        :disbursement_type

  after_destroy :update_orders_disbursements

  scope :by_year, ->(year) { where(disbursed_at: year.beginning_of_year..year.end_of_year) }

  def self.annual_disbursement_report
    select("
    EXTRACT(YEAR FROM disbursed_at) as year,
    COUNT(id) as number_of_disbursements,
    SUM(amount_disbursed) as total_amount_disbursed,
    SUM(amount_fees) as total_amount_fees
  ")
      .group(Arel.sql('EXTRACT(YEAR FROM disbursed_at)'))
      .order(Arel.sql('EXTRACT(YEAR FROM disbursed_at)'))
      .map do |data|
      {
        year: data.year.to_i,
        number: data.number_of_disbursements.to_i,
        total_amount_disbursed: data.total_amount_disbursed.to_f,
        total_amount_fees: data.total_amount_fees.to_f
      }
    end
  end

  private

  def update_orders_disbursements
    orders.update_all(disbursement_id: nil)
  end
end
