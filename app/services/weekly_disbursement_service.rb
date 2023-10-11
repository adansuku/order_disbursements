class WeeklyDisbursementService
  def perform
    merchants_to_disburse_weekly = Merchant.where(disbursement_frequency: 'WEEKLY')
    merchants_to_disburse_weekly.each do |merchant|
      DisbursementWorker.perform_async(merchant.id)
    end
  end
end
