class HealthService
  HEALTHY = "healthy"
  UNHEALTHY = "unhealthy"

  def self.call
    new.call
  end


  def call
    checks = {
    database: database_status
    }

    {

    checks: checks
    }
  end

  private

  def database_status
    ActiveRecord::Base.connection.select_value("SELECT 1")
    HEALTHY
  rescue StandardError
    UNHEALTHY
  end
end
