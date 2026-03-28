class WorkoutTemplateSerializer < ActiveModel::Serializer
  attributes :id, :name, :notes, :is_default, :created_at, :updated_at

  has_many :template_exercises, serializer: TemplateExerciseSerializer
end
