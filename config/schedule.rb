# Use this file to easily define all of your cron jobs
#
# It's helpful to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Schedule daily sleep summary generation at 12:00 AM (midnight) every day
every 1.day, at: "12:00 am" do
  rake "sleep:generate_daily_summaries"
end
