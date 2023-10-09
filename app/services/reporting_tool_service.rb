require 'csv'

class ReportingToolService
  def initialize(combined_info_by_year)
    @combined_info_by_year = combined_info_by_year
  end

  def get_yearly_report
    CSV.generate(headers: true) do |csv|
      csv << ['Year', 'Number of disbursements', 'Amount of order fees',
              'Number of monthly fees charged (From minimum monthly fee)',
              'Amount of monthly fee charged (From minimum monthly fee)']

      @combined_info_by_year.each do |_year, data|
        csv << [
          data[:year],
          data[:number],
          data[:total_amount_disbursed],
          data[:total_amount_fees],
          data[:number_of_monthly_fees],
          data[:total_amount_monthly_fees]
        ]
      end
    end
  end
end
