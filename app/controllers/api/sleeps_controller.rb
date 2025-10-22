# frozen_string_literal: true

module Api
  class SleepsController < BaseController
    before_action :authenticate_user!, only: [ :clock_in, :clock_out, :following_users_sleep_records ]
    before_action :check_active_clock_in, only: [ :clock_in ]
    before_action :set_sleep_for_clock_out, only: [ :clock_out ]
    before_action :validate_following_users_sleep_records_params, only: [ :following_users_sleep_records ]

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

    def following_users_sleep_records
      # Call the service to fetch the sleep records
      service = FollowingUsersSleepRecordsService.new(
        @current_user,
        page: validated_params[:page],
        limit: validated_params[:limit],
        date_start: validated_params[:date_start],
        date_end: validated_params[:date_end]
      )

      sleep_records = service.call

      render_success(
        SleepSerializer.new(sleep_records).serializable_hash
      )
    end

    private

    def validate_following_users_sleep_records_params
      # Prepare params with defaults if needed
      request_params = {
        page: params[:page] || 1,
        limit: params[:limit] || 20,
        date_start: params[:date_start],
        date_end: params[:date_end]
      }

      # Validate the request parameters using the validator class
      validator = FollowingUsersSleepRecordsValidator.new(request_params)

      unless validator.valid?
        render_error(validator.errors.full_messages, :unprocessable_entity)
        return false  # Stop execution of the action
      end

      # Store validated params for use in the action
      @validated_params = request_params
    end

    def validated_params
      @validated_params
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
