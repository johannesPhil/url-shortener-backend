FactoryBot.define do
  sequence(:slug) { |n| "slug#{n}" }

  factory :short_url do
    original_url { Faker::Internet.url }
    slug { generate(:slug) }
    visits { 0 }
  end
end
