class UrlNormalizer
  class InvalidUrl < StandardError; end

  def self.call(raw_url)
    puts "#{raw_url}"
  end

  def initilalize(raw_url)
    @raw_url = raw_url
  end

  def call
    @raw_url
  end

  private
  # placeholders:
  # parse_url
  # normalize_scheme
  # normalize_host
  # normalize_path
  # normalize_query
end
