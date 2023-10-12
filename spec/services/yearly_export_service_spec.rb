require 'rails_helper'

RSpec.describe YearlyExportService do
  describe '#yearly_data' do
    it 'generates a yearly report and logs success' do
      allow(Disbursement).to receive(:annual_disbursement_report).and_return([
                                                                               { year: 2021, number: 10,
                                                                                 total_amount: 5000, total_fees: 200 },
                                                                               { year: 2022, number: 15,
                                                                                 total_amount: 7500, total_fees: 300 }
                                                                             ])
      allow(MonthlyFee).to receive(:monthly_disbursement_report).and_return([
                                                                              { year: 2021, number_of_fees: 5,
                                                                                total_amount: 100 },
                                                                              { year: 2022, number_of_fees: 8,
                                                                                total_amount: 150 }
                                                                            ])

      reporting_tool_service = instance_double(ReportingToolService)
      allow(ReportingToolService).to receive(:new).and_return(reporting_tool_service)
      allow(reporting_tool_service).to receive(:perform).and_return(
        'Year,Number,TotalAmount,TotalFees,NumberOfFees,TotalAmountMonthlyFees
				2021,10,5000,200,5,100
				2022,15,7500,300,8,150'
      )

      allow(File).to receive(:open)
      expect { YearlyExportService.new.yearly_data }.not_to raise_error
    end

    it 'logs an error if an exception occurs' do
      allow(Disbursement).to receive(:annual_disbursement_report).and_raise(StandardError, 'Something went wrong')
      expect { YearlyExportService.new.yearly_data }.to raise_error(StandardError, 'Something went wrong')
    end
  end
end
