class WorkoutTemplateSerializer < ActiveModel::Serializer
  attributes :id, :name, :notes, :created_at, :updated_at

  has_many :template_exercises, serializer: TemplateExerciseSerializer
end
