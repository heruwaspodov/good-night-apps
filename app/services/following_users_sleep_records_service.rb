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

    # Calculate offset manually to avoid the expensive COUNT query
    offset = (@page - 1) * @limit

    # Get the IDs of sleep records in the right order (sorted by duration_minutes DESC)
    sleep_record_ids = Rails.cache.fetch(generate_sleep_ids_cache_key(followed_user_ids), expires_in: 10.minutes) do
      Sleep.where(user_id: followed_user_ids)
           .where(clock_out_time: parse_date_range)
           .order(duration_minutes: :desc)
           .limit(@limit * 20) # Limit to avoid huge result sets
           .pluck(:id)
    end

    # Extract the slice for this page
    paginated_ids = sleep_record_ids[offset...offset + @limit] || []

    # Fetch the actual sleep records with their associated users
    # Order them by finding their position in the original sorted list
    records = Sleep.includes(:user).where(id: paginated_ids)

    # Order results based on the original position in the sorted list
    ordered_records = paginated_ids.map do |id|
      records.find { |record| record.id == id }
    end.compact

    # Return as paginated array without total_count to avoid expensive COUNT query
    Kaminari.paginate_array(ordered_records).page(@page).per(@limit)
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

  def generate_sleep_ids_cache_key(followed_user_ids)
    # Create a cache key for the ordered IDs of sleep records
    # Include date range in the key for proper caching
    timestamp = Sleep.maximum(:updated_at)&.to_i || Time.current.to_i
    # Create a hash of the followed_user_ids to make the key manageable
    followed_ids_hash = Digest::MD5.hexdigest(followed_user_ids.join(","))
    "following_users_sleep_ids_#{@user.id}_#{@date_start}_#{@date_end}_#{followed_ids_hash}_#{timestamp}"
  end
end
