class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    render json: {
      error: "not_found",
      message: "The requested resource could not be found"
    }, status: :not_found
  end
end
