class DailyDisbursementService
  def perform
    merchants_to_disburse_daily = Merchant.where(disbursement_frequency: 'DAILY')

    merchants_to_disburse_daily.each do |merchant|
      DisbursementWorker.perform_async(merchant.id)
    end
  end
end
