class MonthlyFee < ApplicationRecord
  belongs_to :merchant

  def self.monthly_disbursement_report
    select("
      EXTRACT(YEAR FROM month) as year,
      COUNT(id) as number_of_monthly_fees,
      SUM(amount) as total_amount_monthly_fees
    ")
      .group(Arel.sql('EXTRACT(YEAR FROM month)'))
      .order(Arel.sql('EXTRACT(YEAR FROM month)'))
      .map do |data|
        {
          year: data.year.to_i,
          number_of_monthly_fees: data.number_of_monthly_fees.to_i,
          total_amount_monthly_fees: data.total_amount_monthly_fees.to_f
        }
      end
  end
end
