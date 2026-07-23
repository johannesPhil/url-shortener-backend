FactoryBot.define do
  factory :analytics do
    ip_address { Faker::Internet.public_ip_v4_address }
    user_agent { "RSpec" }
    visited_at { Time.current }
    city { nil }
    country { nil }
    association :short_url
  end
end
