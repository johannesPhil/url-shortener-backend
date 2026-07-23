require 'rails_helper'

RSpec.describe IpLocation, type: :model do
  describe ".call" do
    context "when a complete cache entry exists" do
      let(:ip_location) do
        FactoryBot.create(:ip_location,
          ip_address: '8.8.8.8',
          country: 'US',
          city: "Alaska"
        )
      end

      it 'returns the cached location' do
      end

      it 'does not call the API provider' do
      end
    end
  end
end
