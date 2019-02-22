# frozen_string_literal: true

FactoryBot.define do
  factory :event_type, :class => ::EventType do
    sequence(:name) { |i| "event_type-#{i}" }
    sequence(:title) { |i| "Event Type #{i}" }
    sequence(:external_id) { |i| "my-custom-id:#{i}" }

    trait :with_app do
      after(:build) do |instance|
        instance.app = FactoryBot.create(:app)
      end
    end
  end
end
