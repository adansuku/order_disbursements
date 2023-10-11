namespace :import do
  desc 'Import data from CSV files'
  task data: :environment do
    require 'csv'
    require 'ruby-progressbar'
    ActiveRecord::Base.transaction do
      total_rows = CSV.read('./db/dev_data/merchants.csv', headers: true, col_sep: ';').count +
                   CSV.read('./db/dev_data/orders.csv', headers: true, col_sep: ';').count

      progressbar = ProgressBar.create(total: total_rows, format: '%a %e %P% Processed: %c from %C')

      merchant_reference_hash = {}
      CSV.foreach('./db/dev_data/merchants.csv', headers: true, col_sep: ';') do |row|
        merchant_reference_hash[row['reference']] = Merchant.find_or_create_by(row.to_hash)
        progressbar.increment
      end

      CSV.foreach('./db/dev_data/orders.csv', headers: true, col_sep: ';') do |row|
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
