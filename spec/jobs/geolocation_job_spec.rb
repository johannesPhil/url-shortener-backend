require "rails_helper"

RSpec.describe GeolocationJob, type: :job do
  let!(:analytics) do
    FactoryBot.create(
      :analytics,
      # short_url_id: 1233,
      # id: 33444,
      ip_address: "8.8.8.8",
      user_agent: "mozilla",
      visited_at: Time.current,
    )
  end
  describe "::perform" do
    context "Analytics record exists" do
      before do
        allow(GeolocationService).to receive(:call)
                                       .with(analytics.ip_address)
                                       .and_return({
                                         city: "Islamabad",
                                         country: "Pakistan"
                                       })
      end
      it "updates analytics record" do
        described_class.perform_now(analytics.id)

        analytics.reload

        expect(analytics.city).to eq("Islamabad")
        expect(analytics.country).to eq("Pakistan")
      end

      it "exits when the Analytics record no longer exists" do
        analytics = FactoryBot.create(:analytics)
        missing_id = analytics.id

        analytics.destroy!

        expect { described_class.perform_now(missing_id) }.not_to raise_error
      end
    end

    context "Rate limit has been exceeded" do
      before do
        allow(GeolocationService).to receive(:call).and_raise(IpApiProvider::RateLimitExceeded.new(20))
      end

      it "retries the job after the TTLprovided" do
        expect_any_instance_of(described_class).to receive(:retry_job).with(wait: 20.seconds)

        described_class.perform_now(analytics.id)
      end

      it "does not update the analytics record" do
        expect { described_class.perform_now(analytics.id) }.not_to change { analytics.reload.city }
      end
    end
  end
end
