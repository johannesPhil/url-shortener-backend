class SlugGenerator
  def self.call
    new.call
  end

  def call
    potential_slug = SecureRandom.alphanumeric(6)

    potential_slug unless ShortUrl.exists?(slug: potential_slug)
  end
end
