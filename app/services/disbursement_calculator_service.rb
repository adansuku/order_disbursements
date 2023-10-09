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
      calculate_and_create_disbursement(date, order)
    end
  end

  def weekly_disbursement
    start_date = @merchant.live_on.beginning_of_day
    orders_grouped_by_week = {}

    while start_date < Date.today
      end_date = start_date.end_of_day + 6.days

      orders_within_week = @merchant.orders.where(created_at: start_date..end_date)

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
        order.update(disbursement: disbursement) unless order.disbursement
      end

      disbursement.save!
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

  def generate_unique_reference(date)
    "#{@merchant.id}-#{date.strftime('%Y%m%d')}-#{SecureRandom.hex(4)}"
  end
end
