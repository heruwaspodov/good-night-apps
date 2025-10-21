# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

    private

    def handle_standard_error(error)
      Rails.logger.error error.message
      Rails.logger.error error.backtrace.join("\n")

      render json: ApiResponseService.error([
                                              Rails.env.development? ? error.message : "Something went wrong"
                                            ]), status: :internal_server_error
    end

    def handle_not_found(_error)
      render json: ApiResponseService.error([ "Record not found" ]), status: :not_found
    end


    def render_success(data, status = :ok)
      # If data is already in the correct format, use it directly
      if data.is_a?(Hash) && (data.key?(:data) || data.key?(:meta) || data.key?(:error))
        render json: data, status: status
      else
        # Otherwise wrap it in the standard format
        render json: { data: data }, status: status
      end
    end

    def render_error(errors, status = :unprocessable_entity)
      messages = errors.is_a?(Array) ? errors : [ errors ]
      render json: ApiResponseService.error(messages), status: status
    end
  end
end
