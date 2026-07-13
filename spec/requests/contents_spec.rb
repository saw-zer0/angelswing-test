require 'rails_helper'

RSpec.describe "Contents", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:content) { create(:content, user: user) }

  def auth_headers_for(user)
    token = JwtService.encode(
      user_id: user.id,
      exp: 24.hours.from_now.to_i,
      iss: "angelswing_test",
      iat: Time.now.to_i
    )

    { "Authorization" => "Bearer #{token}" }
  end

  describe "GET /api/v1/contents" do
    it "returns all contents" do
      create(:content, user: other_user)

      get "/api/v1/contents", headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["data"].size).to eq(2)
    end
  end

  describe "GET /api/v1/contents/:id" do
    it "returns the requested content" do
      get "/api/v1/contents/#{content.id}", headers: auth_headers_for(user)

      expect(response).to have_http_status(:ok)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.dig("data", "id")).to eq(content.id.to_s)
    end
  end

  describe "POST /api/v1/contents" do
    it "creates content for an authenticated user" do
      headers = auth_headers_for(user)

      expect {
        post "/api/v1/contents", params: {
          content: {
            title: "Hello",
            body: "World"
          }
        }, headers: headers
      }.to change(Content, :count).by(1)

      expect(response).to have_http_status(:ok)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.dig("data", "attributes", "title")).to eq("Hello")
    end

    it "rejects unauthenticated creation" do
      post "/api/v1/contents", params: {
        content: {
          title: "Hello",
          body: "World"
        }
      }

      expect(response).to have_http_status(:unauthorized)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq("Unauthorized")
    end
  end

  describe "PATCH /api/v1/contents/:id" do
    it "updates content owned by the current user" do
      headers = auth_headers_for(user)

      patch "/api/v1/contents/#{content.id}", params: {
        content: {
          title: "Updated title"
        }
      }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(content.reload.title).to eq("Updated title")
    end

    it "rejects updates for content owned by another user" do
      headers = auth_headers_for(other_user)

      patch "/api/v1/contents/#{content.id}", params: {
        content: {
          title: "Updated title"
        }
      }, headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/contents/:id" do
    it "deletes content owned by the current user" do
      headers = auth_headers_for(user)

      expect {
        delete "/api/v1/contents/#{content.id}", headers: headers
      }.to change(Content, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "rejects deletion for content owned by another user" do
      headers = auth_headers_for(other_user)

      expect {
        delete "/api/v1/contents/#{content.id}", headers: headers
      }.to_not change(Content, :count)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
