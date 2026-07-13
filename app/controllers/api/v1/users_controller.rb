class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy ]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)
    @user.save!

    payload = {
      user_id: @user.id,
      exp: 24.hours.from_now.to_i,
      iss: "angelswing_test",
      iat: Time.now.to_i
    }
    token = JwtService.encode(payload)
    serialized_user = Api::V1::UserSerializer.new(@user).serializable_hash
    serialized_user[:data][:attributes].merge!(token: token)
    render json: serialized_user
  end

  # PATCH/PUT /users/1
  def update
    @user.update!(user_params)
    render json: Api::V1::UserSerializer.new(@user).serializable_hash.to_json
  end

  # DELETE /users/1
  def destroy
    @user.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_params
      permitted = params.require(:user).permit(:first_name, :last_name, :email, :country, :password)
      # If password wasn't in the nested hash, pull it from the root params
      if permitted[:password].blank? && params[:password].present?
        permitted[:password] = params[:password]
      end
      permitted
    end
end
