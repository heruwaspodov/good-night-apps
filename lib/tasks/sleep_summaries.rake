namespace :sleep do
  desc "Generate daily sleep summaries for yesterday's sleep records"
  task generate_daily_summaries: :environment do
    puts "Starting daily sleep summary generation for yesterday..."
    DailySleepSummaryJob.perform_now
    puts "Daily sleep summary generation completed."
  end
end
