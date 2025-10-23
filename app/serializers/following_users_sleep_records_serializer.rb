# frozen_string_literal: true

class FollowingUsersSleepRecordsSerializer
  include JSONAPI::Serializer

  attributes :id, :user_id, :clock_in_time, :clock_out_time, :duration_minutes, :created_at, :updated_at

  # Include user object information
  attribute :user do |sleep|
    {
      id: sleep.user.id,
      name: sleep.user.name
    }
  end
end
