FactoryBot.define do
  factory :workout_set do
    workout_exercise
    sequence(:set_order) { |n| n }
    weight { 100.0 }
    reps { 8 }
    completed { false }
  end
end
