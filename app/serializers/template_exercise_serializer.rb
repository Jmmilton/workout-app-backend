class TemplateExerciseSerializer < ActiveModel::Serializer
  attributes :id, :exercise_id, :position, :default_sets, :default_reps,
             :default_weight, :rest_seconds, :notes

  attribute :exercise_name

  def exercise_name
    object.exercise.name
  end

  attribute :muscle_group

  def muscle_group
    object.exercise.muscle_group
  end

  attribute :equipment_type

  def equipment_type
    object.exercise.equipment_type
  end
end
