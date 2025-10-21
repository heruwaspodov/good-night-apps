# frozen_string_literal: true

module Api
  class SleepsController < BaseController
    before_action :authenticate_user!, only: [ :clock_in, :clock_out ]
    before_action :check_active_clock_in, only: [ :clock_in ]
    before_action :set_sleep_for_clock_out, only: [ :clock_out ]

    def clock_in
      result, errors = ClockInService.call(@current_user.id)

      if result
        render_success(SleepSerializer.new(result).serializable_hash)
      else
        render_error(errors, :unprocessable_entity)
      end
    end

    def clock_out
      result, errors = ClockOutService.call(@sleep.id)

      if result
        render_success(SleepSerializer.new(result).serializable_hash)
      else
        render_error(errors, :unprocessable_entity)
      end
    end

    private

    def check_active_clock_in
      # Check if there's already an active clock-in for this user
      active_sleep = Sleep.active.where(user_id: @current_user.id).first
      if active_sleep
        render_error([ "User must clock out before clocking in again" ], :forbidden)
        false
      end
    end

    def set_sleep_for_clock_out
      sleep_record = Sleep.find_by(id: params[:sleep_id])
      unless sleep_record
        render_error([ "Sleep record not found" ], :not_found)
        return false
      end

      # Apply validator for all validations
      validator = SleepClockOutValidator.new(@current_user, sleep_record)

      # Check if validator passes
      unless validator.valid?
        error_messages = validator.errors.full_messages
        render_error(error_messages, :unprocessable_entity)
        return false
      end

      @sleep = sleep_record
    end
  end
end
