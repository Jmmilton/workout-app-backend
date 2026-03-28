FactoryBot.define do
  factory :workout do
    user_id { AuthHelpers::TEST_USER_ID }
    sequence(:name) { |n| "Workout #{n}" }
    started_at { Time.current }
    status { "active" }

    trait :completed do
      status { "completed" }
      completed_at { 1.hour.from_now }
      duration_seconds { 3600 }
    end

    trait :cancelled do
      status { "cancelled" }
      completed_at { Time.current }
    end
  end
end
