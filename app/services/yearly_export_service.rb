require 'csv'

class YearlyExportService
  def yearly_data
    disbursements_info = Disbursement.annual_disbursement_report
    monthly_fees_info = MonthlyFee.monthly_disbursement_report

    combined_info_by_year = {}

    disbursements_info.each do |data|
      year = data[:year]
      combined_info_by_year[year] ||= {}
      combined_info_by_year[year].merge!(data)
    end

    monthly_fees_info.each do |data|
      year = data[:year]
      combined_info_by_year[year] ||= {}
      combined_info_by_year[year].merge!(data)
    end

    service = ReportingToolService.new(combined_info_by_year)
    csv_content = service.get_yearly_report
    File.open('report.csv', 'w') { |file| file.write(csv_content) }

    Rails.logger.info 'Yearly data export completed successfully.'
  rescue StandardError => e
    Rails.logger.error "Oops! Something was wrong, error in YearlyExportService: #{e.message}"
    raise e
  end
end
