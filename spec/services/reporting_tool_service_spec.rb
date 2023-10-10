require 'rails_helper'

RSpec.describe ReportingToolService do
  describe '#get_yearly_report' do
    it 'generates a CSV report with the expected headers and data' do
      combined_info_by_year = {
        2021 => {
          year: 2021,
          number: 10,
          total_amount_disbursed: 5000,
          total_amount_fees: 200,
          number_of_monthly_fees: 5,
          total_amount_monthly_fees: 100
        },
        2022 => {
          year: 2022,
          number: 15,
          total_amount_disbursed: 7500,
          total_amount_fees: 300,
          number_of_monthly_fees: 8,
          total_amount_monthly_fees: 150
        }
      }

      reporting_tool = ReportingToolService.new(combined_info_by_year)

      expected_report = <<~CSV
        Year,Number of disbursements,Amount of order fees,Number of monthly fees charged (From minimum monthly fee),Amount of monthly fee charged (From minimum monthly fee)
        2021,10,5000,200,5,100
        2022,15,7500,300,8,150
      CSV

      generated_report = reporting_tool.get_yearly_report

      expect(generated_report).to eq(expected_report)
    end
  end
end
