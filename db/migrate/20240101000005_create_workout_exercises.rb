class CreateWorkoutExercises < ActiveRecord::Migration[7.2]
  def change
    create_table :workout_exercises do |t|
      t.references :workout, null: false, foreign_key: true
      t.references :exercise, null: false, foreign_key: true
      t.integer :position, null: false
      t.integer :rest_seconds, default: 90
      t.text :notes

      t.timestamps
    end
  end
end
