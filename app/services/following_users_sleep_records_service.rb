class FollowingUsersSleepRecordsService
  def initialize(user, page: 1, limit: 20, date_start: nil, date_end: nil)
    @user = user
    @page = page.to_i
    @limit = limit.to_i
    @date_start = date_start
    @date_end = date_end
  end

  def call
    # Get list of users that the current user is following
    followed_user_ids = Follow.where(follower_id: @user.id).pluck(:followed_id)

    # If no followed users, return empty result
    return Kaminari.paginate_array([]).page(@page).per(@limit) if followed_user_ids.empty?

    # Query sleep records from all followed users within the date range, sorted by duration
    # Using includes to prevent N+1 queries for user data
    sleep_records = Sleep.includes(:user)
                         .where(user_id: followed_user_ids)
                         .where(clock_out_time: parse_date_range)
                         .order(duration_minutes: :desc)
                         .page(@page)
                         .per(@limit)

    sleep_records
  end

  private

  def parse_date_range
    start_date = @date_start ? Date.parse(@date_start) : 1.week.ago.to_date
    end_date = @date_end ? Date.parse(@date_end) : Date.current

    start_date.beginning_of_day..end_date.end_of_day
  end
end
