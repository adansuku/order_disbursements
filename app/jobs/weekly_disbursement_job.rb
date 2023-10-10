class WeeklyDisbursementJob < ApplicationJob
  sidekiq_options retry: 3

  def perform
    WeeklyDisbursementService.new.perform
  rescue StandardError => e
    Rails.logger.error "Opps! Something was wrong, error in WeeklyDisbursementJob: #{e.message}"
    raise e
  end
end
