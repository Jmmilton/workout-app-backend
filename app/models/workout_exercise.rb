class WorkoutExercise < ApplicationRecord
  belongs_to :workout
  belongs_to :exercise
  has_many :workout_sets, -> { order(:set_order) }, dependent: :destroy, inverse_of: :workout_exercise

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :rest_seconds, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
