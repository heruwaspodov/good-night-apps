class Sleep < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :clock_in_time, presence: true

  scope :active, -> { where(clock_out_time: nil) }
  scope :completed, -> { where.not(clock_out_time: nil) }

  after_save :invalidate_following_users_sleep_records_cache
  after_destroy :invalidate_following_users_sleep_records_cache

  private

  def invalidate_following_users_sleep_records_cache
    # Find all users who follow this sleep record's user
    follower_ids = Follow.where(followed_id: user_id).pluck(:follower_id)

    # Invalidate the followed user IDs cache for each follower
    # This will cause a refresh of their sleep records the next time they're requested
    follower_ids.each do |follower_id|
      Rails.cache.delete("user_#{follower_id}_followed_user_ids")
    end
  end
end
