require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  test "should get signin" do
    get api_v1_auth_signin_url
    assert_response :success
  end
end
