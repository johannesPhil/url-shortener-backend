class ApiClientService
  def initialize(url)
    @url = url
  end

  def self.get(url)
    new(url).get
  end

  def get
    uri = URI(@url)
    response = Net::HTTP.get_response(uri)
    response
  end
end
