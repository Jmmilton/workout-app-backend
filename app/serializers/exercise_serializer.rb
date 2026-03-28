class ExerciseSerializer < ActiveModel::Serializer
  attributes :id, :name, :muscle_group, :equipment_type, :description, :notes, :is_default, :created_at
end
