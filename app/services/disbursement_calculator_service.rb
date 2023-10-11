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

  def calculate_and_create_monthly_fee(date)
    last_month_date = date.beginning_of_month.last_month
    orders_last_month_range = @merchant.orders.where(created_at: last_month_date.all_month)

    total_monthly_fee = calculate_monthly_fee(orders_last_month_range)
    chargeable_amount = [@merchant.minimum_monthly_fee - total_monthly_fee, 0].max

    monthly_fee = MonthlyFee.find_or_create_by(merchant: @merchant, month: date.beginning_of_month)
    monthly_fee.update(amount: chargeable_amount)
  end

  def create_monthly_fees_up_to_current_month
    current_month = Time.now.prev_month.end_of_month
    live_on_month = @merchant.live_on.beginning_of_month
    months_between = (live_on_month..current_month).select { |date_item| date_item.day == 1 }

    months_between.each do |date_item|
      calculate_and_create_monthly_fee(date_item)
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

    orders_grouped_by_date.each do |date, _order|
      create_disbursement_and_process_orders(date, orders, @merchant)
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
      create_disbursement_and_process_orders(date, orders, @merchant)
    end
  end

  def create_disbursement_and_process_orders(week_start, orders)
    DisbursementStorageService.new(week_start, orders, @merchant).calculate_and_create_disbursement
  end

  def calculate_monthly_fee(orders)
    orders.sum(&:commission)
  end
end
