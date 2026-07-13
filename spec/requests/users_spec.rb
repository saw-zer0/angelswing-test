require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "POST /api/v1/users/signup" do
    let(:valid_params) do
      {
        user: {
          first_name: "Jane",
          last_name: "Doe",
          email: "jane@example.com",
          password: "StrongPassword123!"
        }
      }
    end

    it "creates a user and returns a token" do
      expect {
        post "/api/v1/users/signup", params: valid_params
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:ok)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.dig("data", "attributes", "email")).to eq("jane@example.com")
      expect(parsed_body.dig("data", "attributes", "token")).to be_present
    end

    it "returns validation errors for invalid signup data" do
      post "/api/v1/users/signup", params: {
        user: {
          first_name: "",
          last_name: "",
          email: "invalid-email",
          password: "weak"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to include("email", "firstName", "lastName", "password")
    end
  end

  describe "GET /api/v1/users" do
    it "returns all users" do
      create_list(:user, 2)

      get "/api/v1/users"

      expect(response).to have_http_status(:ok)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.size).to eq(2)
    end
  end

  describe "GET /api/v1/users/:id" do
    let!(:user) { create(:user) }

    it "returns the requested user" do
      get "/api/v1/users/#{user.id}"

      expect(response).to have_http_status(:ok)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["id"]).to eq(user.id)
      expect(parsed_body["email"]).to eq(user.email)
    end
  end

  describe "PATCH /api/v1/users/:id" do
    let!(:user) { create(:user) }

    it "updates the user" do
      patch "/api/v1/users/#{user.id}", params: {
        user: {
          first_name: "Updated"
        }
      }

      expect(response).to have_http_status(:ok)
      expect(user.reload.first_name).to eq("Updated")
    end
  end

  describe "DELETE /api/v1/users/:id" do
    let!(:user) { create(:user) }

    it "deletes the user" do
      expect {
        delete "/api/v1/users/#{user.id}"
      }.to change(User, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
