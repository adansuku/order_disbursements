class Merchant < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :disbursements, through: :orders
  has_many :monthly_fees, dependent: :destroy

  validates :email, presence: true
  validates :disbursement_frequency, presence: true
  validates :minimum_monthly_fee, presence: true
  validates :reference, presence: true
end
