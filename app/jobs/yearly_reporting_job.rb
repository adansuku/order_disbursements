class YearlyReportingJob < ApplicationJob
  queue_as :default

  def perform
    YearlyExportService.new.yearly_data
  end
end
