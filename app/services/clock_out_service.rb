# frozen_string_literal: true

class ClockOutService < ApplicationService
  def initialize(sleep_id)
    @sleep_id = sleep_id
  end

  def call
    sleep = Sleep.find_by(id: @sleep_id)
    return [ nil, [ "Sleep record not found" ] ] unless sleep

    # Set clock_out_time to current time
    sleep.clock_out_time = Time.current

    # Calculate duration in minutes
    if sleep.clock_in_time
      duration_seconds = (sleep.clock_out_time - sleep.clock_in_time).to_i
      sleep.duration_minutes = (duration_seconds / 60).to_i
    end

    if sleep.save
      [ sleep, nil ]
    else
      [ nil, sleep.errors.full_messages ]
    end
  end
end
