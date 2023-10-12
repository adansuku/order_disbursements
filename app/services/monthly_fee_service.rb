class MonthlyFeeService
  def initialize(merchant = nil, date = nil)
    @merchant = merchant
    @date = date
  end

  def calculate_monthly_fee_from_date
    calculate_and_create_monthly_fee(date)
  end

  def all_months_for_merchant
    create_monthly_fees_up_to_current_month
  end

  def all_months_for_merchants
    Merchant.find_each do |merchant|
      merchant = merchant
      create_monthly_fees_up_to_current_month
    end
  end

  private

  attr_reader :date, :merchant

  def calculate_and_create_monthly_fee(date)
    last_month_date = date.beginning_of_month
    orders_last_month_range = merchant.orders.where(created_at: last_month_date.all_month)

    total_monthly_fee = calculate_monthly_fee(orders_last_month_range)
    chargeable_amount = [merchant.minimum_monthly_fee - total_monthly_fee, 0].max

    MonthlyFee.find_or_create_by(
      merchant_id: merchant.id,
      month: date.next_month.beginning_of_month,
      amount: chargeable_amount
    )
  end

  def create_monthly_fees_up_to_current_month
    current_month = Time.now.prev_month.end_of_month
    live_on_month = merchant.live_on.beginning_of_month
    months_between = (live_on_month..current_month).select { |date_item| date_item.day == 1 }

    months_between.each do |date_item|
      calculate_and_create_monthly_fee(date_item)
    end
  end

  def calculate_monthly_fee(orders)
    orders.sum(&:commission)
  end
end
