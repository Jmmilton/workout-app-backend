FactoryBot.define do
  factory :exercise do
    user_id { AuthHelpers::TEST_USER_ID }
    sequence(:name) { |n| "Exercise #{n}" }
    muscle_group { "chest" }
    equipment_type { "barbell" }
  end
end
