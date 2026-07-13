module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_internal_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActionController::ParameterMissing, with: :handle_bad_request
    rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    rescue_from JWT::DecodeError, with: :handle_unauthorized
  end

  private

  def handle_not_found(exception)
    message = if exception.message.present?
      exception.message.gsub(/with 'id'="?([^"]+)"?/, 'with id \1')
    else
      "Resource not found"
    end

    render json: { error: "Not Found", message: message }, status: :not_found
  end

  def handle_bad_request(exception)
    render json: { error: "Bad Request", message: exception.message }, status: :bad_request
  end

  def handle_validation_error(exception)
    render json: exception.record.errors, status: :unprocessable_content
  end

  def handle_unauthorized(exception)
    render json: { error: "Unauthorized", message: exception.message }, status: :unauthorized
  end

  def handle_internal_error(exception)
    Rails.logger.error("[ErrorHandling] #{exception.class}: #{exception.message}")
    render json: { error: "Internal Server Error", message: exception.message }, status: :internal_server_error
  end

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    render json: {
      error: "Forbidden",
      message: "You are not authorized to perform this action.",
      policy: policy_name
    }, status: :forbidden
  end
end
