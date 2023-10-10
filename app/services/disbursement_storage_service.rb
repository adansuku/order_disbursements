class DisbursementStorageService
  def initialize(date, orders, merchant)
    @date = date
    @orders = orders.reject { |order| order.disbursement_id.present? }
    @merchant = merchant
  end

  def calculate_and_create_disbursement
    ActiveRecord::Base.transaction do
      return if disbursement_exists_for_period? || @orders.empty?

      disbursement = build_disbursement
      process_orders(disbursement)
      save_disbursement(disbursement)
    end
  rescue StandardError => e
    Rails.logger.error("Error during disbursement calculation: #{e.message}")
    raise ActiveRecord::Rollback
  end

  private

  attr_reader :date, :merchant, :orders

  def build_disbursement
    total_order_amount = @orders.sum(&:amount)
    total_commission = @orders.sum(&:commission)
    disbursed_amount = total_order_amount - total_commission

    Disbursement.new(
      reference: generate_unique_reference,
      merchant_id: @merchant.id,
      total_order_amount: total_order_amount,
      amount_disbursed: disbursed_amount,
      amount_fees: total_commission,
      disbursement_type: @merchant.disbursement_frequency,
      disbursed_at: @date
    )
  end

  def process_orders(disbursement)
    @orders.each do |order|
      next if order.disbursement.present?

      unless order.disbursement
        order.update(disbursement: disbursement, commission_fee: order.commission)
        MonthlyDisbursementService.new(order.created_at, @merchant).perform if first_order_of_month?(order)
      end
    end
  end

  def save_disbursement(disbursement)
    disbursement.save
  end

  def first_order_of_month?(order)
    start_of_month = order.created_at.beginning_of_month
    end_of_month = order.created_at - 1.day

    orders_in_month = @merchant.orders.where('created_at >= ? AND created_at <= ?', start_of_month, end_of_month)
    orders_in_month.empty?
  end

  def generate_unique_reference
    "#{@merchant.id}-#{@date.strftime('%Y%m%d')}-#{SecureRandom.hex(4)}"
  end

  def disbursement_exists_for_period?
    existing_disbursement = Disbursement.find_by(
      merchant_id: @merchant.id,
      disbursed_at: @date
    )

    !existing_disbursement.nil?
  end
end
