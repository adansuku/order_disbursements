class Disbursement < ApplicationRecord
  belongs_to :merchant
  has_many :orders, dependent: :nullify

  after_destroy :update_orders_disbursements

  private

  def update_orders_disbursements
    orders.update_all(disbursement_id: nil)
  end
end
