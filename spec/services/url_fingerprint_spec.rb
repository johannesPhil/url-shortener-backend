RSpec.describe UrlIdentifier do
  it "returns hex digest of the normalized URL" do
    fingerprint = described_class.call("https://example.com/path?a=1&b=2")

    expect(fingerprint.length).to eql?(64)
    expect(fingerprint).to match(/\A[0-9a-f]{64}\z/)
  end
end
