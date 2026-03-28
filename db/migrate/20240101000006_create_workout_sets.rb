class CreateWorkoutSets < ActiveRecord::Migration[7.2]
  def change
    create_table :workout_sets do |t|
      t.references :workout_exercise, null: false, foreign_key: true
      t.integer :set_order, null: false
      t.decimal :weight, precision: 7, scale: 2
      t.integer :reps
      t.decimal :distance, precision: 10, scale: 2
      t.integer :duration_seconds
      t.decimal :rpe, precision: 3, scale: 1
      t.boolean :completed, default: false, null: false
      t.datetime :completed_at
      t.text :notes

      t.timestamps
    end
  end
end
