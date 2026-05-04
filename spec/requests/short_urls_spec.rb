require 'rails_helper'

RSpec.describe "ShortUrls", type: :request do
  describe "GET /:slug" do
    context "when slug is found" do
      it "redirects to the original url" do
        short_url = create(:short_url, original_url: 'https://www.ex.com/long-ass-text', slug: 'qwerty', fingerprint: 'abc123')

        get "/#{short_url.slug}"

        expect(response).to redirect_to(short_url.original_url)
      end

      it "increments the visit count" do
        short_url = create(:short_url, original_url: "https://www.ex.com/another-url", slug: 'qazwsx', fingerprint: 'qwe456')

        expect { get "/#{short_url.slug}" }.to change { short_url.reload.visits }.by(1)
      end
    end

    context "when slug is not found" do
      it "returns not found" do
        get "/non-existent-slug"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
