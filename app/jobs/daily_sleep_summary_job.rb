class DailySleepSummaryJob < ApplicationJob
  queue_as :default

  def perform(date = nil)
    # Use yesterday's date if no date is provided
    target_date = date || Date.yesterday

    # Get all users who have sleep records
    user_ids = Sleep.completed
                  .where(clock_out_time: target_date.beginning_of_day..target_date.end_of_day)
                  .select(:user_id)
                  .distinct

    user_ids.each do |user_id|
      # Calculate summary for each user
      sleep_records = Sleep.completed
                           .where(user_id: user_id)
                           .where(clock_out_time: target_date.beginning_of_day..target_date.end_of_day)

      total_duration = sleep_records.sum(:duration_minutes)
      number_of_sessions = sleep_records.count

      # Update or create daily summary record
      DailySleepSummary.find_or_create_by(user_id: user_id, date: target_date) do |summary|
        summary.total_sleep_duration_minutes = total_duration
        summary.number_of_sleep_sessions = number_of_sessions
      end
    end
  end
end
