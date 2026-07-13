class ApplicationController < ActionController::API
  include Pundit::Authorization
  include ErrorHandling

  def welcome
    render json: { message: "This is Angelswing's Cool Test" }
  end
end
