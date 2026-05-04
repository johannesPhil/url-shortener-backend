module Api
  module V1
    class ShortUrlsController < ApplicationController
      def create
        generated_url = ShortUrlCreator.call(get_params[:original_url])
        render json: {
          "original_url" => generated_url.original_url,
          "slug" => generated_url.slug,
          "short_url" => short_url_url(generated_url.slug)
        }, status: :created

      rescue ShortUrlCreator::InvalidUrl
          render json: {
          error: "invalid_url",
          message: "The provided URL is invalid."
          }, status: :unprocessable_entity

      rescue ShortUrlCreator::PersistenceFailed
        render json: {
        error: "creation_failed",
        message: "Failed to create a short URL. Please try again."
        }, status: :internal_server_error
      end

      def stats
        record  = ShortUrl.find_by!(slug: params[:slug])

        render json: {
          slug: record.slug,
          original_url: record.original_url,
          visits: record.visits
        }, status: :ok
      end

      private
      def get_params
        params.permit(:original_url)
      end
    end
  end
end
