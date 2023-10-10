class DailyDisbursementJob < ApplicationJob
  sidekiq_options retry: 3

  def perform
    DailyDisbursementService.new.perform
  rescue StandardError => e
    Rails.logger.error "Opps! Something was worng, error in DailyDisbursementJob: #{e.message}"
    raise e
  end
end
