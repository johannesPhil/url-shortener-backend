class ShortUrlCreator
  class Error < StandardError; end
  class InvalidUrl < Error; end
  class PersistenceFailed < Error;end

  MAX_RETRIES = 3


  def self.call(original_url)
    new(original_url).call
  end

  def initialize(original_url)
    @original_url = original_url
  end

  def call
    normalized_url = UrlNormalizer.call(@original_url)
    fingerprint = UrlIdentifier.call(normalized_url)

    existing_url = ShortUrl.find_by(fingerprint: fingerprint)
    return existing_url if existing_url

    attempts = 0

    ShortUrl.transaction do
      slug = SlugGenerator.call

      ShortUrl.create!(
        original_url: @original_url,
        visits: 0,
        fingerprint: fingerprint,
        slug: slug
      )
    end

    rescue ActiveRecord::RecordNotUnique
      # If another process created the same URL concurrently
      # Try to find it and return it
      existing_url = ShortUrl.find_by(fingerprint: fingerprint)
      return existing_url if existing_url
      
      attempts += 1
      retry if attempts < MAX_RETRIES
      raise PersistenceFailed
    rescue UrlNormalizer::InvalidUrl
      raise InvalidUrl
  end
end
