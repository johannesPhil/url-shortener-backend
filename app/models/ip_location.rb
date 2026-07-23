class IpLocation < ApplicationRecord
  validates :ip_address, presence: true, uniqueness: true
  validates :country, presence: true
  validates :city, presence: true
end
