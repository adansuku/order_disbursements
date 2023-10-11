class DisbursementCalculatorService
  def initialize(merchant)
    @merchant = merchant
  end

  def calculate_and_create_disbursements
    case @merchant.disbursement_frequency
    when 'DAILY'
      daily_disbursement
    when 'WEEKLY'
      weekly_disbursement
    end
  end

  private

  def daily_disbursement
    orders_grouped_by_date = @merchant.orders
                                      .where(disbursement: nil)
                                      .where.not('DATE(created_at) = ?', Date.today)
                                      .group_by do |order|
      order.created_at.to_date
    end

    orders_grouped_by_date.each do |date, order|
      create_disbursement_and_process_orders(date, order)
    end
  end

  def weekly_disbursement
    start_date = @merchant.live_on.beginning_of_day
    orders_grouped_by_week = {}

    while start_date < Date.today
      end_date = start_date.end_of_day + 6.days

      orders_within_week = @merchant.orders.where(created_at: start_date..end_date, disbursement: nil)

      if end_date <= Date.today && !orders_within_week.empty?
        orders_grouped_by_week[start_date] =
          orders_within_week
      end

      start_date += 7.days
    end

    orders_grouped_by_week.each do |date, orders|
      create_disbursement_and_process_orders(date, orders)
    end
  end

  def create_disbursement_and_process_orders(date, orders)
    DisbursementStorageService.new(date, orders, @merchant).calculate_and_create_disbursement
  end

  
end
