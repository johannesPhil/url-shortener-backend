class ShortUrlsController < ApplicationController
  def show
    short_url = ShortUrl.find_by!(slug: params[:slug])
    short_url.increment!(:visits)
    redirect_to short_url.original_url, allow_other_host: true
  end
end
