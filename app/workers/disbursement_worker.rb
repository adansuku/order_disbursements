class DisbursementWorker
  include Sidekiq::Worker

  def perform(merchant_id)
    merchant = Merchant.find(merchant_id)
    DisbursementCalculatorService.new(merchant).calculate_and_create_disbursements
  rescue StandardError => e
    Rails.logger.error "Opps! Something was worng, error in DisbursementWorker: #{e.message}"
    raise e
  end
end
