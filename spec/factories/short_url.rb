FactoryBot.define do
    factory :short_url do
        original_url {Fake::Internet.url}
        slug {sequence(:slug) { |n| "slug#{n}"}}
        visits {0}
    end
end