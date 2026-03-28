FactoryBot.define do
  factory :template_exercise do
    workout_template
    exercise
    sequence(:position) { |n| n }
    default_sets { 3 }
    default_reps { 8 }
    default_weight { 100.0 }
    rest_seconds { 90 }
  end
end
