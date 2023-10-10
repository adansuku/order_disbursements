class DailyDisbursementJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform
    Rails.logger.info 'DailyDisbursementJob started'

    DailyDisbursementService.new.perform
  rescue StandardError => e
    Rails.logger.error "Opps! Something was worng, error in DailyDisbursementJob: #{e.message}"
    raise e
  end
end
