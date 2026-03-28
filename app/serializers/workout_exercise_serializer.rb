class WorkoutExerciseSerializer < ActiveModel::Serializer
  attributes :id, :exercise_id, :position, :rest_seconds, :notes

  attribute :exercise_name
  attribute :muscle_group
  attribute :equipment_type
  attribute :workout_sets

  def exercise_name
    object.exercise.name
  end

  def muscle_group
    object.exercise.muscle_group
  end

  def equipment_type
    object.exercise.equipment_type
  end

  def workout_sets
    object.workout_sets.map do |s|
      WorkoutSetSerializer.new(s).as_json
    end
  end
end
