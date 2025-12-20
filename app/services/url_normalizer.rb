class UrlNormalizer
  class InvalidUrl < StandardError; end

  def self.call(raw_url)
    new(raw_url).call
  end

  def initialize(raw_url)
    @raw_url = raw_url
  end

  def call
    raise InvalidUrl if @raw_url.nil? || @raw_url.strip.empty?

    begin
      @uri = URI.parse(@raw_url)
    rescue URI::InvalidURIError
      raise InvalidUrl
    end

    if @uri.is_a?(URI::Generic) && @raw_url.include?(".")
      # allow missing scheme
    else
      unless @uri.is_a?(URI::HTTP) || @uri.is_a?(URI::HTTPS)
        raise InvalidUrl
      end
    end

    scheme = normalize_scheme(@uri)
    host = normalize_host(@uri,scheme,@raw_url)
    path = normalize_path(@uri)
    queries = normalize_query(@uri)

    normalized = "#{scheme}://#{host}#{path}"

    if queries.any? 
      normalized += "?" + queries.map { |key, value| "#{key}=#{value}" }.join("&")
    end

    {
      scheme: scheme,
      host: host,
      path: path,
      query: queries,
      normalized: normalized,
    }
  end

  private

  def normalize_scheme(uri)
    if uri.scheme.nil?
      "https"
    else
      uri.scheme.downcase
    end
  end

  def normalize_host(uri, scheme, raw_url)
    if uri.host
      uri.host.downcase
    else
      reparsed = URI.parse("#{scheme}://#{raw_url}")
      @uri = reparsed
      reparsed.host.downcase
    end
  end

  # normalize_path
  def normalize_path(uri)
    if  uri.path == '/' || uri.path.empty?
      ""
    else
      uri.path
    end
  end

  # normalize_query
  def normalize_query(uri)
    if uri.query.nil?
      []
    else
      query_pairs = URI.decode_www_form(uri.query)
      queries = query_pairs.sort_by { |key, value| key.downcase }
      queries
    end
  end
end
