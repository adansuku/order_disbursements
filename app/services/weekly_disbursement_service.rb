class WeeklyDisbursementService
  def perform
    merchants_to_disburse_weekly = Merchant.where(disbursement_frequency: 'WEEKLY')
    merchants_to_disburse_weekly.each do |merchant|
      DisbursementCalculatorService.new(merchant).calculate_and_create_disbursements
    end
  end
end
