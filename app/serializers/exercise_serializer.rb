class ExerciseSerializer < ActiveModel::Serializer
  attributes :id, :name, :muscle_group, :equipment_type, :description, :notes, :created_at
end
