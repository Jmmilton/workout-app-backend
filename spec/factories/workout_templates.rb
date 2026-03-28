FactoryBot.define do
  factory :workout_template do
    user_id { AuthHelpers::TEST_USER_ID }
    sequence(:name) { |n| "Template #{n}" }
  end
end
