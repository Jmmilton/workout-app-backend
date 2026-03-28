class CreateTemplateExercises < ActiveRecord::Migration[7.2]
  def change
    create_table :template_exercises do |t|
      t.references :workout_template, null: false, foreign_key: true
      t.references :exercise, null: false, foreign_key: true
      t.integer :position, null: false
      t.integer :default_sets, default: 3
      t.integer :default_reps, default: 8
      t.decimal :default_weight, precision: 7, scale: 2
      t.integer :rest_seconds, default: 90
      t.text :notes

      t.timestamps
    end
  end
end
