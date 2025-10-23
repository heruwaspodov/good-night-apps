require "digest"

class FollowingUsersSleepRecordsService
  def initialize(user, page: 1, limit: 20, date_start: nil, date_end: nil)
    @user = user
    @page = page.to_i
    @limit = limit.to_i
    @date_start = date_start || 1.week.ago.to_date.to_s
    @date_end = date_end || Date.current.to_s
  end

  def call
    # Get list of users that the current user is following with caching
    followed_user_ids = get_followed_user_ids

    # If no followed users, return empty result
    return Kaminari.paginate_array([]).page(@page).per(@limit) if followed_user_ids.empty?

    # Use Kaminari's without_count to avoid expensive COUNT query
    Sleep.includes(:user)
         .where(user_id: followed_user_ids)
         .where(clock_out_time: parse_date_range)
         .order(duration_minutes: :desc)
         .page(@page)
         .per(@limit)
         .without_count
  end

  private

  def get_followed_user_ids
    Rails.cache.fetch("user_#{@user.id}_followed_user_ids", expires_in: 5.minutes) do
      Follow.where(follower_id: @user.id).pluck(:followed_id)
    end
  end

  def parse_date_range
    start_date = Date.parse(@date_start)
    end_date = Date.parse(@date_end)

    start_date.beginning_of_day..end_date.end_of_day
  end
end
