class Api::V1::AuthController < ApplicationController
  def signin
    auth_params = params.require(:auth).permit(:email, :password)
    user = User.authenticate_by(email: auth_params[:email], password: auth_params[:password])
    if user
      payload = {
        user_id: user.id,
        exp: 24.hours.from_now.to_i,
        iss: "angelswing_test",
        iat: Time.now.to_i
      }
      token = JwtService.encode(payload)
      serialized_user = Api::V1::UserSerializer.new(user).serializable_hash
      serialized_user[:data][:attributes].merge!(token: token)
      render json: serialized_user
    else
      raise ActiveRecord::RecordNotFound, "Invalid email or password"
    end
  end

  def authenticate
    header = request.headers["Authorization"]
    header = header.split(" ").last if header

    decoded = JwtService.decode(header)
    @current_user = User.find(decoded[:user_id])
  end
end
