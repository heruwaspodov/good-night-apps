# frozen_string_literal: true

class ClockInService < ApplicationService
  def initialize(user_id)
    @user_id = user_id
  end

  def call
    # Check if user has an active clock-in (without clock_out_time)
    active_sleep = Sleep.active.where(user_id: @user_id).first
    return [ nil, [ "User must clock out before clocking in again" ] ] if active_sleep

    # Create new sleep record with clock_in_time
    sleep = Sleep.new(
      user_id: @user_id,
      clock_in_time: Time.current
    )

    if sleep.save
      [ sleep, nil ]
    else
      [ nil, sleep.errors.full_messages ]
    end
  end
end
