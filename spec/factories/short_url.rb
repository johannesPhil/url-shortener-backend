FactoryBot.define do
  sequence(:slug) { |n| "slug#{n}" }
  sequence(:fingerprint) { |n| "fingerprint#{n}" }

  factory :short_url do
    original_url { Faker::Internet.url }
    slug { generate(:slug) }
    visits { 0 }
    fingerprint { generate(:fingerprint) }
  end
end
