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
      data = parsed_body.fetch("data")
      attributes = data.fetch("attributes")

      expect(parsed_body).to include("data")
      expect(data.fetch("type")).to eq("user")
      expect(data.fetch("id").to_s).to eq(user.id.to_s)
      expect(attributes.fetch("email")).to eq(user.email)
      expect(attributes.fetch("token")).to be_present
      expect(attributes.fetch("name")).to eq(user.first_name + " " + user.last_name)
      expect(attributes.fetch("country")).to eq(user.country)
      expect(attributes.fetch("createdAt")).to be_present
      expect(attributes.fetch("updatedAt")).to be_present
      expect(Time.zone.parse(attributes.fetch("createdAt"))).to be_within(1.second).of(user.created_at)
      expect(Time.zone.parse(attributes.fetch("updatedAt"))).to be_within(1.second).of(user.updated_at)
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
