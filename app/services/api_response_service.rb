# frozen_string_literal: true

class ApiResponseService < ApplicationService
  def self.success(data = nil, meta = nil)
    response = {}
    response[:data] = data if data
    response[:meta] = meta if meta
    response
  end

  def self.error(messages, status = 422)
    {
      error: {
        messages: messages,
        status: status
      }
    }
  end
end
