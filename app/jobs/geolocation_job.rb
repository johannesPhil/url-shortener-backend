class GeolocationJob < ApplicationJob
  queue_as :default

  retry_on Net::HTTPClientException,
    Net::HTTPServerException,
    wait: :exponentially_longer,
    attempts: 5

  def perform(analytics_id)
    analytics_record = Analytics.find_by(id: analytics_id)
    return unless analytics_record

    location = GeolocationService.call(analytics_record.ip_address)

    analytics_record.update!(
      city: location[:city],
      country: location[:country],
    )

    rescue IpApiProvider::RateLimitExceeded=> error
      retry_job wait: error.ttl
  end
end
