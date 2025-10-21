# frozen_string_literal: true

module Api
  class SleepsController < BaseController
    before_action :authenticate_user!, only: [ :clock_in ]
    before_action :check_active_clock_in, only: [ :clock_in ]

    def clock_in
      result, errors = ClockInService.call(@current_user.id)

      if result
        render_success(SleepSerializer.new(result).serializable_hash)
      else
        render_error(errors, :unprocessable_entity)
      end
    end

    private

    def authenticate_user!
      user_id = request.headers["X-User-Id"]
      return render_error([ "X-User-Id header is required" ], :unauthorized) unless user_id

      @current_user = User.find_by(id: user_id)
      render_error([ "User not found" ], :unauthorized) unless @current_user
    end

    def check_active_clock_in
      # Check if there's already an active clock-in for this user
      active_sleep = Sleep.active.where(user_id: @current_user.id).first
      if active_sleep
        render_error([ "User must clock out before clocking in again" ], :forbidden)
        false
      end
    end
  end
end
