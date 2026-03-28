class CreateExercises < ActiveRecord::Migration[7.2]
  def change
    create_table :exercises do |t|
      t.uuid :user_id, null: false
      t.string :name, null: false
      t.string :muscle_group
      t.string :equipment_type
      t.text :notes

      t.timestamps
    end

    add_index :exercises, [:user_id, :name], unique: true
    add_index :exercises, :user_id
  end
end
