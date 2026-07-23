class IpApiProvider
  class RateLimitExceeded < StandardError
    attr_reader :ttl

    def initialize(ttl)
      @ttl = ttl.to_i
      super("Rate limit exceeded. Try again later in #{@ttl} seconds")
    end
  end

  BASE_URL = "http://ip-api.com/json"

  def self.lookup(ip_address)
    ensure_not_rate_limited!
    url = "#{BASE_URL}/#{ip_address}"
    response = ApiClientService.get(url)
    parsed_response = JSON.parse(response.body)

    headers = extract_headers(response)

    remember_ttl(headers) if headers[:limit].to_i.zero?

    if parsed_response["status"] == "success"
      {
        city: parsed_response["city"],
        country: parsed_response["country"]

      }
    end
  end

  private

  def self.ensure_not_rate_limited!
    ttl = Rails.cache.read("ip_api_rate_limit")
    raise RateLimitExceeded.new(ttl) if ttl
  end

  def self.extract_headers(response)
    {
      limit: response["X-Rl"],
      ttl: response["X-Ttl"]
    }
  end

  def self.remember_ttl(headers)
    Rails.cache.write("ip_api_rate_limit", headers[:ttl].to_i, expires_in: headers[:ttl].to_i.seconds)
  end
end
