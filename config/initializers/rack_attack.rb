class Rack::Attack
  Rack::Attack.cache.store = Rails.cache

  throttle("limit URL creation by IP", limit: 10, period: 60) do |request|
    if request.post? && request.path=="/api/v1/short_urls"
      request.ip
    end
  end

  self.throttled_responder = lambda do |request|
      match_data = request.env["rack.attack.match_data"]

      body = {
        error: "rate_limited",
        message: "Too many attempts at URL creation. Please try again later."
      }.to_json

      headers = {
      "Content-Type" => "application/json",
      "Retry-After" => match_data[:period].to_s
    }

    [ 429, headers, [ body ] ]
  end
end
