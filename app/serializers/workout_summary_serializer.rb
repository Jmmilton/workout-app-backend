class WorkoutSummarySerializer < ActiveModel::Serializer
  attributes :id, :name, :started_at, :completed_at, :duration_seconds,
             :status, :workout_template_id

  attribute :exercise_count
  attribute :set_count

  def exercise_count
    if object.respond_to?(:cached_exercise_count)
      object.cached_exercise_count.to_i
    else
      object.workout_exercises.size
    end
  end

  def set_count
    if object.respond_to?(:cached_set_count)
      object.cached_set_count.to_i
    else
      object.workout_sets.size
    end
  end
end
