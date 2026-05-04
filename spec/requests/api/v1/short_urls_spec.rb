require 'rails_helper'

RSpec.describe "Api::v1::ShortUrls", type: :request do
   let(:original_url) { "https://www.example.com/some-long-winded-url" }
  describe "POST /api/v1/short_urls"  do
    context "with valid URL" do
      it "creates a short URL" do
        expect {
          post '/api/v1/short_urls', params: {
            original_url: original_url
            }
          }.to change(ShortUrl, :count).by(1)
          expect(response).to have_http_status(:created)
      end

      it "returns short URL as JSON" do
        # let! (:original_url) { "https://www.example.com/some-long-winded-url" }
        expect {
          post "/api/v1/short_urls", params: {
            original_url: original_url
          }
        }.to change(ShortUrl, :count).by(1)
        body = JSON.parse(response.body)

        expect(body["original_url"]).to eq(original_url)
        expect(body["slug"]).to be_present
        expect(body["short_url"]).to include(body["slug"])
      end
    end

    context "with invalid URL" do
      it "returns an error response" do
        expect {
          post "/api/v1/short_urls", params: {
            original_url: "invalid-url"
              }
          }.not_to change(ShortUrl, :count)
      body =  JSON.parse(response.body)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(body["error"]).to eq("invalid_url")
      expect(body["message"]).to be_present
      end

      it 'does not create a short URL' do
        expect {
          post "/api/v1/short_urls", params: {
            original_url: "invalid-url"
          }
        }.not_to change(ShortUrl, :count)
      end
    end
  end

  describe "GET /api/v1/short_urls/:slug/stats" do
    it "returns stats for an existing slug" do
      record =  create(:short_url, slug: 'abc123', visits: 5)
      get "/api/v1/short_urls/abc123/stats"
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body["slug"]).to eq(record.slug)
      expect(body["original_url"]).to eq(record.original_url)
      expect(body).to have_key('visits')
      expect(body["visits"]).to eq(5)
    end

    it "returns not found for nonexistent slug" do
      get "/api/v1/short_urls/invalid-slug/stats"
      expect(response).to have_http_status(:not_found)
    end
  end
end
