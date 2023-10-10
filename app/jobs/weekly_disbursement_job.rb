class WeeklyDisbursementJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: 3

  def perform
    Rails.logger.info 'WeeklyDisbursementJob started'
    WeeklyDisbursementService.new.perform
  rescue StandardError => e
    Rails.logger.error "Opps! Something was wrong, error in WeeklyDisbursementJob: #{e.message}"
    raise e
  end
end
