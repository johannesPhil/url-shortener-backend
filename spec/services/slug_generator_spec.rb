require 'rails_helper'

RSpec.describe SlugGenerator do
  let(:normalized_url) { "https://example.com/path?id=1" }

  describe ".call" do
      it "returns a 6-character alpha-numeric string" do
        allow(ShortUrl).to receive(:exists?).and_return(false)
        result = described_class.call

        expect(result).to be_a(String)
        expect(result).to match(/^[a-zA-Z0-9]{6}$/)
      end
  end
end
