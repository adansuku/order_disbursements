class DailyDisbursementService
  def perform
    merchants_to_disburse_daily = Merchant.where(disbursement_frequency: 'DAILY')

    merchants_to_disburse_daily.each do |merchant|
      DisbursementCalculatorService.new(merchant).calculate_and_create_disbursements
    end
  end
end
