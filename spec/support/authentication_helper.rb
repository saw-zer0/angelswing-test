module AuthHelper
  def authenticate_user(user)
    post '/api/v1/auth/signin', params: { email: user.email, password: user.password }
    token = JSON.parse(response.body)['token']
    { 'Authorization' => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
