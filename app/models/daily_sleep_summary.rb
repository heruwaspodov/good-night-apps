class DailySleepSummary < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :date, presence: true

  scope :for_date, ->(date) { where(date: date) }
  scope :for_user, ->(user) { where(user: user) }
end
