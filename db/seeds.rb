# Seed default exercises and sample workouts for testing.
#
# Usage:
#   SEED_USER_ID=your-supabase-user-uuid rails db:seed
#
# You MUST provide your real Supabase user ID. Find it in Supabase Dashboard > Authentication > Users.

unless ENV["SEED_USER_ID"]
  abort "ERROR: Set SEED_USER_ID to your Supabase user UUID.\n  Example: SEED_USER_ID=abc-123 rails db:seed"
end

user_id = ENV["SEED_USER_ID"]

puts "Seeding data for user: #{user_id}"

# --- Default Exercises ---
created = DefaultExerciseSeeder.new(user_id).call
puts "  Exercises: #{created} created (#{DefaultExerciseSeeder::EXERCISES.size - created} already existed)"

# --- Sample Workouts (3 weeks, 4 days/week) ---
exercises = Exercise.where(user_id: user_id).index_by(&:name)

# Workout templates: name → [[exercise_name, sets, rep_range, weight_range]]
programs = {
  "Push Day" => [
    ["Bench Press (Barbell)", 4, 6..8, 135..185],
    ["Incline Bench Press (Dumbbell)", 3, 8..10, 40..60],
    ["Shoulder Press (Dumbbell)", 3, 8..10, 35..50],
    ["Lateral Raise (Dumbbell)", 3, 10..15, 15..25],
    ["Triceps Pushdown (Cable)", 3, 10..12, 40..60],
    ["Chest Fly (Dumbbell)", 3, 10..12, 25..40],
  ],
  "Pull Day" => [
    ["Deadlift (Barbell)", 3, 3..5, 185..275],
    ["Bent Over Row (Barbell)", 4, 6..8, 115..155],
    ["Lat Pulldown (Cable)", 3, 8..10, 100..140],
    ["Seated Row (Cable)", 3, 8..10, 90..130],
    ["Bicep Curl (Dumbbell)", 3, 10..12, 25..40],
    ["Face Pull (Cable)", 3, 12..15, 30..50],
  ],
  "Leg Day" => [
    ["Squat (Barbell)", 4, 5..8, 155..225],
    ["Romanian Deadlift (Barbell)", 3, 8..10, 135..185],
    ["Leg Press (Machine)", 3, 10..12, 200..360],
    ["Leg Extension (Machine)", 3, 10..12, 80..120],
    ["Leg Curl (Machine)", 3, 10..12, 70..100],
    ["Calf Raise (Machine)", 4, 12..15, 100..160],
  ],
  "Upper Body" => [
    ["Bench Press (Barbell)", 3, 8..10, 135..165],
    ["Bent Over Row (Dumbbell)", 3, 8..10, 45..65],
    ["Overhead Press (Barbell)", 3, 6..8, 85..115],
    ["Hammer Curl (Dumbbell)", 3, 10..12, 25..35],
    ["Skullcrusher (Barbell)", 3, 10..12, 50..70],
    ["Reverse Fly (Dumbbell)", 3, 12..15, 12..20],
  ],
}

# Generate 3 weeks of workouts: Mon/Tue/Thu/Fri pattern
schedule = ["Push Day", "Pull Day", "Leg Day", "Upper Body"]
base_date = 3.weeks.ago.beginning_of_week

workout_count = 0
set_count = 0

3.times do |week|
  week_start = base_date + week.weeks
  training_days = [0, 1, 3, 4] # Mon, Tue, Thu, Fri

  training_days.each_with_index do |day_offset, idx|
    workout_date = week_start + day_offset.days
    start_hour = [6, 7, 6, 7][idx]
    started_at = workout_date.change(hour: start_hour, min: rand(0..30))
    duration = rand(45..75) * 60

    program_name = schedule[idx]
    program = programs[program_name]

    workout = Workout.find_or_create_by!(
      user_id: user_id,
      name: program_name,
      started_at: started_at
    ) do |w|
      w.completed_at = started_at + duration.seconds
      w.duration_seconds = duration
      w.status = "completed"
    end

    next unless workout.workout_exercises.empty?

    program.each_with_index do |exercise_def, position|
      ex_name, num_sets, rep_range, weight_range = exercise_def
      exercise = exercises[ex_name]
      next unless exercise

      we = WorkoutExercise.create!(
        workout: workout,
        exercise: exercise,
        position: position + 1
      )

      num_sets.times do |set_idx|
        weight = rand(weight_range)
        weight = (weight / 2.5).round * 2.5 # Round to nearest 2.5
        reps = rand(rep_range)
        # Simulate slight fatigue: later sets may have fewer reps
        reps = [reps - rand(0..1), rep_range.min].max if set_idx >= 2

        WorkoutSet.create!(
          workout_exercise: we,
          set_order: set_idx + 1,
          weight: weight,
          reps: reps,
          completed: true,
          completed_at: started_at + (position * 8 + set_idx * 2).minutes
        )
        set_count += 1
      end
    end

    workout_count += 1
  end
end

puts "  Workouts: #{workout_count} created"
puts "  Sets: #{set_count} created"
puts "Done!"
