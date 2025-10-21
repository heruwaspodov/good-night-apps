class Sleep < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :clock_in_time, presence: true

  scope :active, -> { where(clock_out_time: nil) }
  scope :completed, -> { where.not(clock_out_time: nil) }
end
