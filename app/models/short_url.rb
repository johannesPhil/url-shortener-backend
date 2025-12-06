class ShortUrl < ApplicationRecord
    validates :original_url, presence: true
    validates :slug, presence: true, uniqueness: true
    validates :visits,presence:true, numericality:{only_integer: true}
end
