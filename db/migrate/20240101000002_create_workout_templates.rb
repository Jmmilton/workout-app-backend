class CreateWorkoutTemplates < ActiveRecord::Migration[7.2]
  def change
    create_table :workout_templates do |t|
      t.uuid :user_id, null: false
      t.string :name, null: false
      t.text :notes

      t.timestamps
    end

    add_index :workout_templates, :user_id
  end
end
