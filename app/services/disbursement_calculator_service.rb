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

    orders_grouped_by_date.each do |date, order|
      calculate_and_create_disbursement(date, order)
    end
  end

  def weekly_disbursement
    start_date = @merchant.live_on.beginning_of_day
    orders_grouped_by_week = {}

    while start_date < Date.today
      end_date = start_date.end_of_day + 6.days

      orders_within_week = @merchant.orders.where(created_at: start_date..end_date, disbursement: nil)

      if end_date.end_of_day <= Date.today && !orders_within_week.empty?
        orders_grouped_by_week[start_date] = orders_within_week
      end

      start_date += 7.days
    end

    orders_grouped_by_week.each do |date, orders|
      calculate_and_create_disbursement(date, orders)
    end
  end

  def calculate_and_create_disbursement(date, orders)
    ActiveRecord::Base.transaction do
      return false if orders.empty?

      total_order_amount = orders.sum(&:amount)
      total_commission = orders.sum(&:commission)
      disbursed_amount = total_order_amount - total_commission

      disbursement = Disbursement.new(
        reference: generate_unique_reference(date),
        merchant_id: @merchant.id,
        total_order_amount: total_order_amount,
        amount_disbursed: disbursed_amount,
        amount_fees: total_commission,
        disbursement_type: @merchant.disbursement_frequency,
        disbursed_at: date
      )

      orders.each do |order|
        next if order.disbursement.present?

        unless order.disbursement
          order.update(disbursement: disbursement)
          MonthlyDisbursementService.new(order.created_at, @merchant).perform if first_order_of_month?(order)
        end
      end

      disbursement.save
    rescue StandardError => e
      Rails.logger.error("Error during disbursement calculation: #{e.message}")
      raise ActiveRecord::Rollback
    end
  end

  def first_order_of_month?(order)
    start_of_month = order.created_at.beginning_of_month
    end_of_month = order.created_at - 1.day

    orders_in_month = @merchant.orders.where('created_at >= ? AND created_at <= ?', start_of_month, end_of_month)
    orders_in_month.empty?
  end

  def calculate_monthly_fee(orders)
    orders.sum(&:commission)
  end

  def generate_unique_reference(date)
    "#{@merchant.id}-#{date.strftime('%Y%m%d')}-#{SecureRandom.hex(4)}"
  end
end
