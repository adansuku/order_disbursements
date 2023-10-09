class Order < ApplicationRecord
  belongs_to :merchant
  belongs_to :disbursement, optional: true

  def commission
    if amount < 50
      amount * 0.01
    elsif amount >= 50 && amount <= 300
      amount * 0.0095
    else
      amount * 0.0085
    end.round(2)
  end
end
