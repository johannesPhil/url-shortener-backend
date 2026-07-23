require "rails_helper"

RSpec.describe IpApiProvider do
  describe ".lookup" do
    context "API request is succesful" do
      before do
        Rails.cache.clear
        stub_request(:get, "http://ip-api.com/json/101.89.45.102")
          .to_return(
            status: 200,
            body: '{
                    "status"       : "success",
                    "continent"    : "Africa",
                    "continentCode": "AF",
                    "country"      : "Nigeria",
                    "countryCode"  : "NG",
                    "region"       : "LA",
                    "regionName"   : "Lagos",
                    "city"         : "Lagos",
                    "district"     : "",
                    "zip"          : "",
                    "lat"          : 6.4474,
                    "lon"          : 3.3903,
                    "timezone"     : "Africa/Lagos",
                    "offset"       : 3600,
                    "currency"     : "NGN",
                    "isp"          : "MTN NIGERIA Communication limited",
                    "org"          : "MTN Nigeria",
                    "as"           : "AS29465 MTN NIGERIA Communication limited",
                    "asname"       : "VCG-AS",
                    "mobile"       : true,
                    "proxy"        : false,
                    "hosting"      : true,
                    "query"        : "101.89.45.102"
                  }',
            headers: {
              "X-Ttl" => 16,
              "X-Rl" => 43
            },
          )
      end

      it "returns location hash" do
        result = described_class.lookup("101.89.45.102")
        expect(result).to include(
          city: "Lagos",
          country: "Nigeria",
        )
      end

      it "cache the ttl when the remaining request reaches zero" do
        stub_request(:get, "http://ip-api.com/json/101.89.45.102")
          .to_return(
            status: 200,
            body: '{
              "city": "Lagos",
              "country": "Nigeria"
            }',
            headers: {
              "X-Rl" => 0,
              "X-Ttl" => 20
            },
          )
        described_class.lookup("101.89.45.102")
        expect(Rails.cache.read("ip_api_rate_limit")).to be_present
      end
    end
  end
end
