# frozen_string_literal: true

module Api
  class FollowsController < BaseController
    before_action :authenticate_user!

    def follow
      result, errors = FollowService.call(@current_user.id, params[:user_id])

      if result
        render_success({ message: "Successfully followed user" })
      else
        render_error(errors, :unprocessable_entity)
      end
    end

    def unfollow
      result, errors = UnfollowService.call(@current_user.id, params[:user_id])

      if result
        render_success({ message: "Successfully unfollowed user" })
      else
        render_error(errors, :unprocessable_entity)
      end
    end
  end
end
