FactoryBot.define do
  sequence(:ip_address) { |n|"192.168.1.#{n}" }

  factory :ip_location do
    ip_address { generate(:ip_address) }
    country { Faker::Address.country }
    city { Faker::Address.city }
    updated_at { Time.current }
  end
end
