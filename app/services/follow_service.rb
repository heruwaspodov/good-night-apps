# frozen_string_literal: true

class FollowService < ApplicationService
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

    # Validate not trying to follow self
    return [ nil, [ "Cannot follow yourself" ] ] if @follower_id == @followed_id

    # Validate not already following
    existing_follow = Follow.find_by(follower_id: @follower_id, followed_id: @followed_id)
    return [ nil, [ "Already following this user" ] ] if existing_follow

    # Create follow record
    follow = Follow.new(
      follower_id: @follower_id,
      followed_id: @followed_id
    )

    if follow.save
      [ follow, nil ]
    else
      [ nil, follow.errors.full_messages ]
    end
  end
end
