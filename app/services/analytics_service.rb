class AnalyticsService
  def self.call(short_url_id, ip_address, user_agent)
    new(short_url_id, ip_address, user_agent).call
  end

  def initialize(short_url_id, ip_address, user_agent)
    @short_url_id = short_url_id
    @ip_address = ip_address
    @user_agent = user_agent
  end

  def call
  begin
    Analytics.transaction do
      Analytics.create!(
        short_url_id: @short_url_id,
        ip_address: @ip_address,
        user_agent: @user_agent,
        visited_at: Time.current,

      )
    end
  rescue ActiveRecord::RecordInvalid => e


  end
  end
end
