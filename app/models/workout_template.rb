class WorkoutTemplate < ApplicationRecord
  has_many :template_exercises, -> { order(:position) }, dependent: :destroy, inverse_of: :workout_template
  has_many :exercises, through: :template_exercises
  has_many :workouts, dependent: :nullify

  accepts_nested_attributes_for :template_exercises, allow_destroy: true

  validates :name, presence: true
  validates :user_id, presence: true
end
