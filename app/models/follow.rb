class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validates :follower_id, uniqueness: { scope: :followed_id }

  # Prevent users from following themselves
  validate :cannot_follow_yourself

  private

  def cannot_follow_yourself
    if follower_id == followed_id
      errors.add(:followed_id, "can't be the same as follower")
    end
  end
end
