namespace :import do
  desc 'Import data from CSV files'
  task data: :environment do
    require 'csv'
    require 'ruby-progressbar'
    ActiveRecord::Base.transaction do
      merchants_data = './db/original_data/merchants.csv'
      orders_data = './db/original_data/orders.csv'
      total_rows = CSV.read(merchants_data, headers: true, col_sep: ';').count +
                   CSV.read(orders_data, headers: true, col_sep: ';').count

      progressbar = ProgressBar.create(total: total_rows, format: '%a %e %P% Processed: %c from %C')

      merchant_reference_hash = {}
      CSV.foreach(merchants_data, headers: true, col_sep: ';') do |row|
        merchant_reference_hash[row['reference']] = Merchant.find_or_create_by(row.to_hash)
        progressbar.increment
      end

      CSV.foreach(orders_data, headers: true, col_sep: ';') do |row|
        Order.create!(
          merchant: merchant_reference_hash[row['merchant_reference']],
          amount: row['amount'].to_f,
          created_at: Date.parse(row['created_at']),
          disbursement: nil
        )
        progressbar.increment
      end

      progressbar.finish
    end
  end
end
