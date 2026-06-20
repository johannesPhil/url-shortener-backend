class ShortUrl < ApplicationRecord
    has_many :analytics, dependent: :destroy
    validates :original_url, presence: true
    validates :slug, uniqueness: true
    validates :visits, numericality: { only_integer: true }
    validates :fingerprint, presence: true, uniqueness: true
end
