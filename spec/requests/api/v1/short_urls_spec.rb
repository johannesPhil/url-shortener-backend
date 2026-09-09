require 'rails_helper'

RSpec.describe "Api::v1::ShortUrls", type: :request do
   let(:original_url) { "Example.com/some-long-winded-url?b=2&a=1" }
   let(:normalized_url) { "https://example.com/some-long-winded-url?a=1&b=2" }
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

        expect(body["original_url"]).to eq(normalized_url)
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

  describe "GET #stats" do
    let!(:short_url) do
      FactoryBot.create(:short_url)
    end

      context "when analytics exist" do
    let!(:analytics) do
      FactoryBot.create(
        :analytics,
        short_url: short_url,
        ip_address: "203.0.113.42",
        user_agent: "Mozilla/5.0",
        city: "Lagos",
        country: "Nigeria",
        visited_at: Time.current
      )
    end

    it "returns the analytics for the short URL" do
      get stats_api_v1_short_url_path(short_url.slug)

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["slug"]).to eq(short_url.slug)
      expect(body["original_url"]).to eq(short_url.original_url)
      expect(body["visits"]).to eq(short_url.visits)

      expect(body["analytics"]).to include(
        include(
          "city" => "Lagos",
          "country" => "Nigeria",
          "user_agent" => "Mozilla/5.0",
          "visited_at" => analytics.visited_at.iso8601(3)
        )
      )

      expect(body["analytics"].first).not_to have_key("ip_address")
    end
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

  describe "rate limiting" do
  it "rate limits URL creation by IP" do
    10.times do
      post "/api/v1/short_urls", params: {
        original_url: "https://example.com/page"
      }
    end

    post "/api/v1/short_urls", params: {
      original_url: "https://example.com/page"
    }

    body = JSON.parse(response.body)

    expect(response).to have_http_status(:too_many_requests)
    expect(body["error"]).to eq("rate_limited")
  end
end
end
