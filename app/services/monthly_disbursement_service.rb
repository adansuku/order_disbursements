class MonthlyDisbursementService
  def initialize(date = nil, merchant = nil)
    @date = date
    @merchant = merchant
  end

  def perform
    DisbursementCalculatorService.new(@merchant).calculate_and_create_monthly_fee(@date.to_date.beginning_of_month)
  end

  def all_months_all_merchants
    Merchant.find_each do |merchant|
      DisbursementCalculatorService.new(merchant).create_monthly_fees_up_to_current_month
    end
  end

  def all_months
    DisbursementCalculatorService.new(@merchant).create_monthly_fees_up_to_current_month
  end
end
