namespace :import do
  desc 'Import data from CSV files'
  task data: :environment do
    require 'csv'
    require 'ruby-progressbar'

    # Count the total number of rows in the CSV files for progress bar
    total_rows = CSV.read('./db/original_data/merchants.csv', headers: true, col_sep: ';').count +
                 CSV.read('./db/original_data/orders.csv', headers: true, col_sep: ';').count

    progressbar = ProgressBar.create(total: total_rows, format: '%a %e %P% Processed: %c from %C')

    # Import merchants
    CSV.foreach('./db/original_data/merchants.csv', headers: true, col_sep: ';') do |row|
      Merchant.create!(row.to_hash)
      progressbar.increment
    end

    # Import orders
    CSV.foreach('./db/original_data/orders.csv', headers: true, col_sep: ';') do |row|
      Order.create!(
        merchant: Merchant.find_by(reference: row['merchant_reference']),
        amount: row['amount'].to_f,
        created_at: Date.parse(row['created_at']),
        disbursement: nil
      )
      progressbar.increment
    end

    # Finish the progress bar when the import is complete
    progressbar.finish
  end
end
