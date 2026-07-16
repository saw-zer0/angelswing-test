require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "POST /api/v1/users/signup" do
    let(:valid_params) do
      {
        user: attributes_for(
          :user,
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          email: Faker::Internet.unique.email,
          password: Faker::Internet.password(min_length: 12, mix_case: true, special_characters: true)
        )
      }
    end

    it "creates a user and returns a token" do
      expect {
        post "/api/v1/users/signup", params: valid_params
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:ok)
      parsed_body = JSON.parse(response.body)
      data = parsed_body.fetch("data")
      attributes = data.fetch("attributes")

      expect(parsed_body).to include("data")
      expect(data.fetch("type")).to eq("user")
      expect(data.fetch("id")).to be_present
      expect(attributes.fetch("email")).to eq(valid_params[:user][:email])
      expect(attributes.fetch("name")).to eq("#{valid_params[:user][:first_name]} #{valid_params[:user][:last_name]}")
      expect(attributes.fetch("country")).to eq(valid_params[:user][:country])
      expect(attributes.fetch("token")).to be_present
      expect(attributes.fetch("createdAt")).to be_present
      expect(attributes.fetch("updatedAt")).to be_present
    end

    it "returns validation errors for invalid signup data" do
      post "/api/v1/users/signup", params: {
        user: {
          first_name: "",
          last_name: "",
          email: "invalid-email#{Faker::Number.number(digits: 3)}",
          password: Faker::Internet.password(min_length: 6)
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

    it "returns a JSON error for a missing user" do
      get "/api/v1/users/999999"

      expect(response).to have_http_status(:not_found)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq("Not Found")
    end
  end

  describe "PATCH /api/v1/users/:id" do
    let!(:user) { create(:user) }

    it "updates the user" do
      updated_first_name = Faker::Name.first_name

      patch "/api/v1/users/#{user.id}", params: {
        user: {
          first_name: updated_first_name
        }
      }

      expect(response).to have_http_status(:ok)
      parsed_body = JSON.parse(response.body)
      expect(user.reload.first_name).to eq(updated_first_name)
      expect(parsed_body.dig("data", "attributes", "name")).to include(updated_first_name)
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
