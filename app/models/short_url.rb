class ShortUrl < ApplicationRecord
    validates :original_url, presence: true
    validates :slug, uniqueness: true, allow_nil: true
    validates :visits, numericality:{only_integer: true}
end
