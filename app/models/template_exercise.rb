class TemplateExercise < ApplicationRecord
  belongs_to :workout_template
  belongs_to :exercise

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :default_sets, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :default_reps, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :default_weight, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :rest_seconds, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
