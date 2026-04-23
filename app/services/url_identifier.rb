module UrlIdentifier
  def self.call(normalized_url)
    Digest::SHA256.hexdigest(normalized_url)
  end
end
