class SlugGenerator
  def self.call
    SecureRandom.alphanumeric(6)
  end
end
