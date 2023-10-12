class DisbursementCalculatorService
  def initialize(merchant)
    @merchant = merchant
  end

  def calculate_and_create_disbursements
    case merchant.disbursement_frequency
    when 'DAILY'
      daily_disbursement
    when 'WEEKLY'
      weekly_disbursement
    end
  end

  private

  attr_reader :merchant

  def daily_disbursement
    orders_grouped_by_date = merchant.pending_daily_orders_for_disbursement

    orders_grouped_by_date.each do |date, order|
      create_disbursement_and_process_orders(date, order)
    end
  end

  def weekly_disbursement
    orders_grouped_by_week = merchant.pending_weekly_orders_for_disbursement

    orders_grouped_by_week.each do |date, orders|
      create_disbursement_and_process_orders(date, orders)
    end
  end

  def create_disbursement_and_process_orders(date, orders)
    DisbursementStorageService.new(date, orders, merchant).calculate_and_create_disbursement
  end
end
