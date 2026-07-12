class ApplicationController < ActionController::API
  include Pundit::Authorization

  # Global error handling for unauthorized requests
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized(exception)
    # Optional: Extract the specific query/policy that failed
    policy_name = exception.policy.class.to_s.underscore

    render json: {
      error: "Forbidden",
      message: "You are not authorized to perform this action.",
      policy: policy_name
    }, status: :forbidden
  end
end
