class YearlyReportingJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform
    Rails.logger.info 'YearlyReportingJob started'

    YearlyExportService.new.yearly_data
  rescue StandardError => e
    Rails.logger.error "Opps! Something was wrong, error in YearlyReportingJob: #{e.message}"
    raise e
  end
end
