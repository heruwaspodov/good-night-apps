# frozen_string_literal: true

class SleepClockOutValidator
  include ActiveModel::Validations

  attr_accessor :user, :sleep_record

  def initialize(user, sleep_record)
    @user = user
    @sleep_record = sleep_record
  end

  validate :validate_user_owns_record
  validate :validate_clock_in_time_present
  validate :validate_clock_out_time_absent

  private

  def validate_user_owns_record
    return if user && sleep_record && sleep_record.user_id == user.id

    errors.add(:sleep_record, "invalid sleep record")
  end

  def validate_clock_in_time_present
    return if sleep_record && sleep_record.clock_in_time.present?

    errors.add(:clock_in_time, "must be present for clock out")
  end

  def validate_clock_out_time_absent
    return unless sleep_record && sleep_record.clock_out_time.present?

    errors.add(:clock_out_time, "is already set")
  end
end
