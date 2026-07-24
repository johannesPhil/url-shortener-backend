# module Api
#   module V1
#     class AnalyticsController < ApplicationController
#       short_url = ShortUrl.find_by!(slug: params[:slug])
#       short_url.increment!(:visits)
#       ip_address = extract_ip
#       user_agent = request.user_agent
#       AnalyticsService.call(short_url.id, ip_address, user_agent)

#       private

#       def extract_ip
#         # Check for Cloudfare direct user header
#         if request.headers["CF-Connecting-IP"].present?
#           request.headers["CF-Connecting-IP"]
#         end

#         if request.headers["X-Forwarded-For"].present?
#           originating_ip = request.headers["X-Forwarded-For"].split(",").first&.strip
#           return originating_ip if valid_ip?(originating_ip)
#         end

#         request.remote_ip
#       end

#       def valid_ip?(ip_address)
#         false if ip_address.blank?

#         ip_object = IPAddr.new(ip_address)

#         !(ip_object.loopback? || ip_object.private)
#       rescue IPAddr::InvalidAddressError
#         false
#       end
#     end
#   end
# end
