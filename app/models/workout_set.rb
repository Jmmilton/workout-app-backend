class WorkoutSet < ApplicationRecord
  belongs_to :workout_exercise

  validates :set_order, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :weight, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :reps, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :rpe, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true

  def complete!
    update!(completed: true, completed_at: Time.current)
  end

  def uncomplete!
    update!(completed: false, completed_at: nil)
  end
end
