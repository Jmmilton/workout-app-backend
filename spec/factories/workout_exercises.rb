FactoryBot.define do
  factory :workout_exercise do
    workout
    exercise
    sequence(:position) { |n| n }
    rest_seconds { 90 }
  end
end
