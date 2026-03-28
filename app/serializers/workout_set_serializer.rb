class WorkoutSetSerializer < ActiveModel::Serializer
  attributes :id, :set_order, :weight, :reps, :distance, :duration_seconds,
             :rpe, :completed, :completed_at, :notes
end
