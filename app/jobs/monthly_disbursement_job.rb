class MonthlyDisbursementJob < ApplicationJob
  queue_as :default  
sidekiq_options retry: 3

  def perform
    Rails.logger.info 'MonthlyDisbursementJob started'

    MonthlyDisbursementService.new.all_months_all_merchants
  rescue StandardError => e
    Rails.logger.error "Opps! Something was worng, error in MonthlyDisbursementJob: #{e.message}"
    raise e
  end
end
