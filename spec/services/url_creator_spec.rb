require "rails_helper"

RSpec.describe ShortUrlCreator do
  describe ".call" do
    context "when the URL is valid" do
    let(:original_url) { "https://www.example.com/path?id=1" }

    before do
      allow(UrlNormalizer).to receive(:call).and_return({
      scheme: "https",
      host: "example.com",
      path: "/path",
      query: "id=1",
      normalized: "https://example.com/path?id=1"
      })
    end
      it "creates a short URL record" do
        expect { described_class.call(original_url) }.to change { ShortUrl.count }.by(1)
      end

      it "returns persisted URL" do
        result = described_class.call(original_url)

        expect(result).to be_a(ShortUrl)
        expect(result).to be_persisted
      end

      it "sets visits to 0" do
        result = described_class.call(original_url)

        expect(result.visits).to eq(0)
      end

      it
    end
  end

  context "when URL is invalid" do
    let(:original_url) { 'invalid-url' }

    before do
      allow(UrlNormalizer).to receive(:call).and_raise(UrlNormalizer::InvalidUrl)
    end

    it "raises ShortUrlCreator::InvalidUrl" do
      expect { described_class.call(original_url) }.to raise_error(ShortUrlCreator::InvalidUrl)
    end

    it "does not create a short URL record" do
      expect { begin
        described_class.call(original_url)
      rescue ShortUrlCreator::InvalidUrl
      end
      }.not_to change { ShortUrl.count }
    end
  end

  context "when persistence fails" do
    let(:original_url) { "https://example.com" }


    before do
      allow(UrlNormalizer).to receive(:call).and_return(
        {
          scheme: 'https',
          host: 'example.com',
          path: '/',
          query: '',
          normalized: 'https://example.com'
        }
      )

      allow_any_instance_of(ShortUrl).to receive(:save!).and_return(false)
    end

    it "raises ShortUrlCreator::PersistenceFailed" do
      expect { described_class.call(original_url) }.to raise_error(ShortUrlCreator::PersistenceFailed)
    end

    it 'does not persist anything' do
      expect {
        begin
          described_class.call(original_url)
        rescue ShortUrlCreator::PersistenceFailed
        end
      }.not_to change { ShortUrl.count }
    end
  end

  context "slug generation" do
  let(:original_url) { "https://example.com" }

    before do
      allow(UrlNormalizer).to receive(:call).and_return(
        {
        scheme: 'https',
        host: 'example.com',
        path: '/',
        query: '',
        normalized: 'https://example.com'
        }
      )
      allow(SlugGenerator).to receive(:call).and_return('abc123')
    end

    it "assigns a slug to the created record" do
      result = described_class.call(original_url)

      expect(result.slug).to eq('abc123')
    end
  end

  context "when a slug collison occurs" do
    let(:original_url) { "https://example.com" }

    before do
      allow(UrlNormalizer).to receive(:call).and_return(
        {
        scheme: 'https',
        host: 'example.com',
        path: '/',
        query: '',
        normalized: 'https://example.com'
        }
      )

      allow(SlugGenerator).to receive(:call).and_return("abc123,abc123,def456")
    end

    it "retries and returns a unique slug" do
      create(:short_url, slug: 'abc123')
      result = described_class.call(original_url)

      expect(result.slug).to eq('def456')
    end
  end

  context "slug generation keeps colliding" do
    let(:original_url) { "https://example.com" }

    before do
      allow(UrlNormalizer).to receive(:call).and_return(
        {
        scheme: "https",
        host: "example.com",
        path: "/",
        query: "",
        normalized: "https://example.com"
        }
      )

      allow(SlugGenerator).to receive(:call).and_return("abc123", "abc123", "def456")
    end

    it "raises PersistenceFailed error" do
      create(:short_url, slug: 'abc123')
      expect { described_class.call(original_url) }.to raise_error(ShortUrlCreator::PersistenceFailed)
    end

    it "does not persist a record" do
      create(:short_url, slug: 'abc123')
      expect {
        begin
          described_class.call(original_url)
        rescue ShortUrlCreator::PersistenceFailed
        end
      }.not_to change { ShortUrl.count }
    end
  end
end
