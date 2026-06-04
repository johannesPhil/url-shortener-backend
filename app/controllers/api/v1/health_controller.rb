
module Api
  module V1
    class HealthController < ApplicationController
      def show
      result = HealthService.call
      status = result[:checks][:database] == HealthService::HEALTHY ?
        :ok :
        :service_unavailable
        render json: result, status: status
      end
    end
  end
end
