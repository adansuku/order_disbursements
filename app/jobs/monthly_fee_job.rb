class MonthlyFeeJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform
    Rails.logger.info 'MonthlyFeeJob started'

    MonthlyFeeService.new.all_months_for_merchants
  rescue StandardError => e
    Rails.logger.error "Opps! Something was worng, error in MonthlyFeeJob: #{e.message}"
    raise e
  end
end
