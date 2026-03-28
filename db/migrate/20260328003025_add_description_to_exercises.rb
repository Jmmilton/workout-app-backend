class AddDescriptionToExercises < ActiveRecord::Migration[7.2]
  def change
    add_column :exercises, :description, :text
  end
end
