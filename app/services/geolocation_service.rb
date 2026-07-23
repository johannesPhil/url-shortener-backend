class GeolocationService
  class PersistenceFailed < StandardError; end

  def initialize(ip_address)
    @ip_address = ip_address
  end

  def self.call(ip_address)
    new(ip_address).call
  end

  def call
    # Use the ip_address to check the IpLocation table if it exists
    cached_location = IpLocation.find_by(ip_address: @ip_address)

    if cached_location
      return {
               city: cached_location.city,
               country: cached_location.country
             }
    end
    # Make the API call using the API service that makes use of Net::HTTP
    ip_response = IpApiProvider.lookup(@ip_address)

    begin
      location_query = nil
      IpLocation.transaction do
        location_query = IpLocation.create!(
          ip_address: @ip_address,
          city: ip_response[:city],
          country: ip_response[:country],
        )
      end
      {
        city: location_query[:city],
        country: location_query[:country]
      }
    rescue ActiveRecord::RecordInvalid
      raise PersistenceFailed
    end
  end
end
