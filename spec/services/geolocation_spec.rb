require "rails_helper"

RSpec.describe GeolocationService do
  describe ".call" do
    context "when a complete cache entry exists" do
      let!(:ip_location) do
        FactoryBot.create(:ip_location,
                          ip_address: "8.8.8.8",
                          country: "US",
                          city: "Alaska")
      end

      let(:url) { "http://ip-api.com/json/8.8.8.8" }

      it "retrieves the cache location" do
        result = described_class.call("8.8.8.8")
        expect(result).to include(
          country: "US",
          city: "Alaska",
        )
      end

      it "does not call the API provider" do
        described_class.call("8.8.8.8")

        expect(WebMock).not_to have_requested(:get, url)
      end
    end

    context "when IP address is not in cache" do
      let(:ip_response) do
        {
          city: "Islamabad",
          country: "Pakistan"
        }
      end

      before do
        allow(IpApiProvider).to receive(:lookup).with("8.8.8.8").and_return(ip_response)
      end

      it "looks up the IP and fetches location and cache it" do
        expect { described_class.call("8.8.8.8") }.to change(IpLocation, :count).by(1)

        expect(IpApiProvider).to have_received(:lookup).with("8.8.8.8")

        cached = IpLocation.find_by(ip_address: "8.8.8.8")
        expect(cached.city).to eq("Islamabad")
        expect(cached.country).to eq("Pakistan")
      end

      it 'returns the IP location' do
        result = described_class.call("8.8.8.8")

        expect(result).to eq(ip_response)
      end
    end
  end
end
