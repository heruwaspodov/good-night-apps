# frozen_string_literal: true

class UnfollowService < ApplicationService
  def initialize(follower_id, followed_id)
    @follower_id = follower_id
    @followed_id = followed_id
  end

  def call
    # Validate required params
    return [ nil, [ "User ID is required" ] ] if @followed_id.blank?

    # Validate user exists
    followed_user = User.find_by(id: @followed_id)
    return [ nil, [ "User not found" ] ] unless followed_user

    # Validate not trying to unfollow self
    return [ nil, [ "Cannot unfollow yourself" ] ] if @follower_id == @followed_id

    # Validate already following (must exist to unfollow)
    existing_follow = Follow.find_by(follower_id: @follower_id, followed_id: @followed_id)
    return [ nil, [ "Not following this user" ] ] unless existing_follow

    # Delete the follow record
    if existing_follow.destroy
      [ existing_follow, nil ]
    else
      [ nil, existing_follow.errors.full_messages ]
    end
  end
end
