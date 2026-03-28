class WorkoutSerializer < ActiveModel::Serializer
  attributes :id, :name, :started_at, :completed_at, :duration_seconds,
             :status, :notes, :workout_template_id, :created_at, :updated_at

  has_many :workout_exercises, serializer: WorkoutExerciseSerializer
end
