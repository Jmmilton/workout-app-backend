class CreateWorkouts < ActiveRecord::Migration[7.2]
  def change
    create_table :workouts do |t|
      t.uuid :user_id, null: false
      t.references :workout_template, foreign_key: true
      t.string :name, null: false
      t.datetime :started_at, null: false
      t.datetime :completed_at
      t.integer :duration_seconds
      t.string :status, null: false, default: "active"
      t.text :notes

      t.timestamps
    end

    add_index :workouts, [:user_id, :started_at]
    add_index :workouts, [:user_id, :status]
  end
end
