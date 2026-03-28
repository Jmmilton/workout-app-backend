class Workout < ApplicationRecord
  belongs_to :workout_template, optional: true
  has_many :workout_exercises, -> { order(:position) }, dependent: :destroy, inverse_of: :workout
  has_many :workout_sets, through: :workout_exercises

  validates :name, presence: true
  validates :user_id, presence: true
  validates :started_at, presence: true
  validates :status, presence: true, inclusion: { in: %w[active completed cancelled] }

  scope :active, -> { where(status: "active") }
  scope :completed, -> { where(status: "completed") }
  scope :by_date, ->(start_date, end_date) {
    where(started_at: start_date.beginning_of_day..end_date.end_of_day)
  }

  def complete!
    now = Time.current
    update!(
      status: "completed",
      completed_at: now,
      duration_seconds: (now - started_at).to_i
    )
  end

  def cancel!
    update!(status: "cancelled", completed_at: Time.current)
  end
end
