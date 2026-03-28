class Exercise < ApplicationRecord
  has_many :template_exercises, dependent: :restrict_with_error
  has_many :workout_exercises, dependent: :restrict_with_error
  has_many :workout_templates, through: :template_exercises

  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :user_id, presence: true

  MUSCLE_GROUPS = %w[chest back shoulders arms legs abs forearms].freeze
  EQUIPMENT_TYPES = %w[barbell dumbbell cable machine smith_machine bodyweight other].freeze

  validates :muscle_group, inclusion: { in: MUSCLE_GROUPS }, allow_blank: true
  validates :equipment_type, inclusion: { in: EQUIPMENT_TYPES }, allow_blank: true
end
