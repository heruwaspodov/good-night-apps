class FollowingUsersSleepRecordsValidator
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :page, :integer
  attribute :limit, :integer
  attribute :date_start, :string
  attribute :date_end, :string

  validates :page, presence: true, numericality: { greater_than: 0 }
  validates :limit, presence: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: 100
  }
  validates :date_start, presence: true
  validates :date_end, presence: true

  validate :valid_date_formats
  validate :valid_date_range

  private

  def valid_date_formats
    unless date_start&.match?(/^\d{4}-\d{2}-\d{2}$/)
      errors.add(:date_start, "must be in YYYY-MM-DD format")
    else
      begin
        Date.parse(date_start)
      rescue Date::Error
        errors.add(:date_start, "must be a valid date in YYYY-MM-DD format")
      end
    end

    unless date_end&.match?(/^\d{4}-\d{2}-\d{2}$/)
      errors.add(:date_end, "must be in YYYY-MM-DD format")
    else
      begin
        Date.parse(date_end)
      rescue Date::Error
        errors.add(:date_end, "must be a valid date in YYYY-MM-DD format")
      end
    end
  end

  def valid_date_range
    return if errors.any? # Skip if date format validation already failed

    start_date = Date.parse(date_start)
    end_date = Date.parse(date_end)

    if start_date > end_date
      errors.add(:date_start, "must be before or equal to date_end")
    end

    # Check if the range exceeds 3 months
    if end_date > start_date + 3.months
      errors.add(:date_end, "date range cannot exceed 3 months")
    end
  rescue Date::Error
    # Date parsing errors are handled in valid_date_formats
  end
end
