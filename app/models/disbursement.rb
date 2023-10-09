class Disbursement < ApplicationRecord
  belongs_to :merchant
  has_many :orders, dependent: :nullify
end
