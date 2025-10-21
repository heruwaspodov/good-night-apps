class User < ApplicationRecord
  has_many :sleeps, dependent: :destroy
  has_many :daily_sleep_summaries, dependent: :destroy
  has_many :active_follows, class_name: "Follow", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_follows, class_name: "Follow", foreign_key: "followed_id", dependent: :destroy

  validates :name, presence: true
end
