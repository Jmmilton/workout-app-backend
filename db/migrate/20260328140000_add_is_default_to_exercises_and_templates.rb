class AddIsDefaultToExercisesAndTemplates < ActiveRecord::Migration[7.2]
  def change
    add_column :exercises, :is_default, :boolean, default: false, null: false
    add_column :workout_templates, :is_default, :boolean, default: false, null: false
  end
end
