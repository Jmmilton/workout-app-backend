# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_03_28_003025) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "exercises", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "name", null: false
    t.string "muscle_group"
    t.string "equipment_type"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["user_id", "name"], name: "index_exercises_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_exercises_on_user_id"
  end

  create_table "template_exercises", force: :cascade do |t|
    t.bigint "workout_template_id", null: false
    t.bigint "exercise_id", null: false
    t.integer "position", null: false
    t.integer "default_sets", default: 3
    t.integer "default_reps", default: 8
    t.decimal "default_weight", precision: 7, scale: 2
    t.integer "rest_seconds", default: 90
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_template_exercises_on_exercise_id"
    t.index ["workout_template_id"], name: "index_template_exercises_on_workout_template_id"
  end

  create_table "workout_exercises", force: :cascade do |t|
    t.bigint "workout_id", null: false
    t.bigint "exercise_id", null: false
    t.integer "position", null: false
    t.integer "rest_seconds", default: 90
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_workout_exercises_on_exercise_id"
    t.index ["workout_id"], name: "index_workout_exercises_on_workout_id"
  end

  create_table "workout_sets", force: :cascade do |t|
    t.bigint "workout_exercise_id", null: false
    t.integer "set_order", null: false
    t.decimal "weight", precision: 7, scale: 2
    t.integer "reps"
    t.decimal "distance", precision: 10, scale: 2
    t.integer "duration_seconds"
    t.decimal "rpe", precision: 3, scale: 1
    t.boolean "completed", default: false, null: false
    t.datetime "completed_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workout_exercise_id"], name: "index_workout_sets_on_workout_exercise_id"
  end

  create_table "workout_templates", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "name", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_workout_templates_on_user_id"
  end

  create_table "workouts", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.bigint "workout_template_id"
    t.string "name", null: false
    t.datetime "started_at", null: false
    t.datetime "completed_at"
    t.integer "duration_seconds"
    t.string "status", default: "active", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "started_at"], name: "index_workouts_on_user_id_and_started_at"
    t.index ["user_id", "status"], name: "index_workouts_on_user_id_and_status"
    t.index ["workout_template_id"], name: "index_workouts_on_workout_template_id"
  end

  add_foreign_key "template_exercises", "exercises"
  add_foreign_key "template_exercises", "workout_templates"
  add_foreign_key "workout_exercises", "exercises"
  add_foreign_key "workout_exercises", "workouts"
  add_foreign_key "workout_sets", "workout_exercises"
  add_foreign_key "workouts", "workout_templates"
end
