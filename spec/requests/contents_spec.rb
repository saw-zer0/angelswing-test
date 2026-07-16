require 'rails_helper'

RSpec.describe "Contents", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:content) { create(:content, user: user, title: Faker::Lorem.sentence(word_count: 4), body: Faker::Lorem.paragraph) }

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
      data = parsed_body.fetch("data")
      first_content = data.first
      first_attributes = first_content.fetch("attributes")

      expect(data).to be_an(Array)
      expect(data.size).to eq(2)
      expect(first_content.fetch("type")).to eq("content")
      expect(first_attributes.fetch("title")).to be_present
      expect(first_attributes.fetch("body")).to be_present
      expect(first_attributes.fetch("createdAt")).to be_present
      expect(first_attributes.fetch("updatedAt")).to be_present
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
      title = Faker::Lorem.sentence(word_count: 3)
      body = Faker::Lorem.paragraph

      expect {
        post "/api/v1/contents", params: {
          content: {
            title: title,
            body: body
          }
        }, headers: headers
      }.to change(Content, :count).by(1)

      expect(response).to have_http_status(:ok)
      parsed_body = JSON.parse(response.body)
      data = parsed_body.fetch("data")
      attributes = data.fetch("attributes")

      expect(parsed_body).to include("data")
      expect(data.fetch("type")).to eq("content")
      expect(attributes.fetch("title")).to eq(title)
      expect(attributes.fetch("body")).to eq(body)
      expect(attributes.fetch("createdAt")).to be_present
      expect(attributes.fetch("updatedAt")).to be_present
    end

    it "rejects unauthenticated creation" do
      post "/api/v1/contents", params: {
        content: {
          title: Faker::Lorem.sentence(word_count: 3),
          body: Faker::Lorem.paragraph
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

      updated_title = Faker::Lorem.sentence(word_count: 4)

      patch "/api/v1/contents/#{content.id}", params: {
        content: {
          title: updated_title
        }
      }, headers: headers

      expect(response).to have_http_status(:ok)
      parsed_body = JSON.parse(response.body)
      data = parsed_body.fetch("data")
      attributes = data.fetch("attributes")

      expect(data.fetch("type")).to eq("content")
      expect(attributes.fetch("title")).to eq(updated_title)
      expect(attributes.fetch("body")).to eq(content.reload.body)
      expect(attributes.fetch("createdAt")).to be_present
      expect(attributes.fetch("updatedAt")).to be_present
      expect(content.reload.title).to eq(updated_title)
    end

    it "rejects updates for content owned by another user" do
      headers = auth_headers_for(other_user)

      updated_title = Faker::Lorem.sentence(word_count: 4)

      patch "/api/v1/contents/#{content.id}", params: {
        content: {
          title: updated_title
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

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ "message" => "Deleted" })
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
