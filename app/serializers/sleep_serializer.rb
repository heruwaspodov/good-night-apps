# frozen_string_literal: true

class SleepSerializer
  include JSONAPI::Serializer

  attributes :id, :user_id, :clock_in_time, :clock_out_time, :duration_minutes, :created_at, :updated_at
end
