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
    attempts = 0

    begin
      normalized_url = UrlNormalizer.call(@original_url)
      fingerprint = UrlIdentifier.call(normalized_url[:normalized])

      existing_url = ShortUrl.find_by(fingerprint: fingerprint)
      return existing_url if existing_url

      ShortUrl.transaction do
        slug = SlugGenerator.call

        ShortUrl.create!(
          original_url: @original_url,
          visits: 0,
          fingerprint: fingerprint,
          slug: slug
        )
      end

    rescue ActiveRecord::RecordInvalid => e
      # Check if it's a slug error for retry, or fingerprint for re-find
      if e.record&.errors&.added?(:slug, :taken)|| e.message.include?("Slug")
          attempts += 1
          retry if attempts < MAX_RETRIES
          raise PersistenceFailed
      end


      if e.record&.errors&.added?(:fingerprint, :taken)|| e.message.include?("Fingerprint")
        existing_url = ShortUrl.find_by(fingerprint: fingerprint)
        return existing_url if existing_url
      end

      raise PersistenceFailed

    rescue ActiveRecord::RecordNotUnique
      existing_url = ShortUrl.find_by(fingerprint: fingerprint)
      return existing_url if existing_url
      attempts += 1
      retry if attempts < MAX_RETRIES
      raise PersistenceFailed

    rescue UrlNormalizer::InvalidUrl
      raise InvalidUrl
    end
  end
end
