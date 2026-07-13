require 'rails_helper'

RSpec.describe "Auth", type: :request do
  describe "POST /api/v1/auth/signin" do
    let(:user) { create(:user, email: Faker::Internet.unique.email) }

    it "returns a token for valid credentials" do
      post "/api/v1/auth/signin", params: {
        auth: {
          email: user.email,
          password: user.password
        }
      }

      expect(response).to have_http_status(:ok)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.dig("data", "attributes", "email")).to eq(user.email)
      expect(parsed_body.dig("data", "attributes", "token")).to be_present
    end

    it "returns unauthorized for invalid credentials" do
      post "/api/v1/auth/signin", params: {
        auth: {
          email: user.email,
          password: Faker::Internet.password(min_length: 12, mix_case: true, special_characters: true)
        }
      }

      expect(response).to have_http_status(:not_found)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq("Not Found")
    end
  end

  describe "POST /api/v1/auth/authenticate" do
    let(:user) { create(:user) }
    let(:token) do
      JwtService.encode(
        user_id: user.id,
        exp: 24.hours.from_now.to_i,
        iss: "angelswing_test",
        iat: Time.now.to_i
      )
    end

    it "accepts a valid bearer token" do
      post "/api/v1/auth/authenticate", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:no_content)
      expect(response.body).to eq("")
    end

    it "rejects an invalid bearer token" do
      post "/api/v1/auth/authenticate", headers: { "Authorization" => "Bearer invalid-token" }

      expect(response).to have_http_status(:unauthorized)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq("Unauthorized")
    end
  end
end
