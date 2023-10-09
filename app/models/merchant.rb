class Merchant < ApplicationRecord
  has_many :orders
  has_many :disbursements
end
