require "rails_helper"

RSpec.describe CsvImporter do
  let(:user_id) { AuthHelpers::TEST_USER_ID }
  let(:csv_content) { File.read(Rails.root.join("spec/fixtures/sample_import.csv")) }

  describe "#call" do
    it "creates exercises, workouts, and sets from CSV" do
      result = described_class.new(csv_content, user_id).call

      expect(result.exercises_created).to eq(6)
      expect(result.workouts_created).to eq(3)
      expect(result.sets_created).to eq(13)
    end

    it "creates exercises with correct attributes" do
      described_class.new(csv_content, user_id).call

      bench = Exercise.find_by(name: "Bench Press (Barbell)", user_id: user_id)
      expect(bench).to be_present
      expect(bench.equipment_type).to eq("barbell")

      lateral = Exercise.find_by(name: "Lateral Raise (Dumbbell)", user_id: user_id)
      expect(lateral.equipment_type).to eq("dumbbell")

      dip = Exercise.find_by(name: "Chest Dip (Assisted)", user_id: user_id)
      expect(dip.equipment_type).to eq("bodyweight")

      pulldown = Exercise.find_by(name: "Pull-down Triangle", user_id: user_id)
      expect(pulldown).to be_present
      expect(pulldown.equipment_type).to be_nil
    end

    it "strips trailing whitespace from exercise and workout names" do
      described_class.new(csv_content, user_id).call

      expect(Exercise.find_by(name: "Pull-down Triangle", user_id: user_id)).to be_present
      expect(Workout.find_by(name: "Back & Forearm", user_id: user_id)).to be_present
    end

    it "creates workouts with correct attributes" do
      described_class.new(csv_content, user_id).call

      push = Workout.find_by(name: "Push Day", user_id: user_id)
      expect(push.status).to eq("completed")
      expect(push.started_at).to eq(Time.zone.parse("2024-01-15 08:00:00"))
      expect(push.duration_seconds).to eq(3900)
      expect(push.notes).to eq("First workout")
    end

    it "parses various duration formats" do
      described_class.new(csv_content, user_id).call

      push = Workout.find_by(name: "Push Day", user_id: user_id)
      expect(push.duration_seconds).to eq(3900) # 1h 5min

      back = Workout.find_by(name: "Back & Forearm", user_id: user_id)
      expect(back.duration_seconds).to eq(2700) # 45min

      legs = Workout.find_by(name: "Legs", user_id: user_id)
      expect(legs.duration_seconds).to eq(27) # 27s
    end

    it "rounds weight floats to 2 decimals" do
      described_class.new(csv_content, user_id).call

      push = Workout.find_by(name: "Push Day", user_id: user_id)
      bench_exercise = push.workout_exercises.joins(:exercise).find_by(exercises: { name: "Bench Press (Barbell)" })
      third_set = bench_exercise.workout_sets.find_by(set_order: 3)

      expect(third_set.weight).to eq(137.5)
    end

    it "sets nil weight for bodyweight exercises with zero weight" do
      described_class.new(csv_content, user_id).call

      push = Workout.find_by(name: "Push Day", user_id: user_id)
      dip_exercise = push.workout_exercises.joins(:exercise).find_by(exercises: { name: "Chest Dip (Assisted)" })
      first_set = dip_exercise.workout_sets.find_by(set_order: 1)

      expect(first_set.weight).to be_nil
      expect(first_set.reps).to eq(10)
    end

    it "creates workout exercises with correct positions" do
      described_class.new(csv_content, user_id).call

      push = Workout.find_by(name: "Push Day", user_id: user_id)
      exercises = push.workout_exercises.order(:position).includes(:exercise)

      expect(exercises.length).to eq(3)
      expect(exercises[0].exercise.name).to eq("Bench Press (Barbell)")
      expect(exercises[0].position).to eq(1)
      expect(exercises[1].exercise.name).to eq("Lateral Raise (Dumbbell)")
      expect(exercises[1].position).to eq(2)
      expect(exercises[2].exercise.name).to eq("Chest Dip (Assisted)")
      expect(exercises[2].position).to eq(3)
    end

    it "stores set notes" do
      described_class.new(csv_content, user_id).call

      back = Workout.find_by(name: "Back & Forearm", user_id: user_id)
      pulldown_exercise = back.workout_exercises.joins(:exercise).find_by(exercises: { name: "Pull-down Triangle" })
      first_set = pulldown_exercise.workout_sets.find_by(set_order: 1)

      expect(first_set.notes).to eq("heavy set")
    end

    it "marks all imported sets as completed" do
      described_class.new(csv_content, user_id).call

      user_sets = WorkoutSet.joins(workout_exercise: :workout).where(workouts: { user_id: user_id })
      expect(user_sets.where(completed: false).count).to eq(0)
      expect(user_sets.where(completed: true).count).to eq(13)
    end

    it "wraps everything in a transaction and rolls back on error" do
      # Duplicate exercise name for a different user_id triggers uniqueness error within the same import
      # Use a CSV that creates a workout with an exercise, then a second workout referencing a non-existent date format
      bad_csv = "Date,Workout Name,Duration,Exercise Name,Set Order,Weight,Reps,Distance,Seconds,Notes,Workout Notes,RPE\n" \
                "invalid-date,\"Bad\",1min,\"Test Exercise\",1,100.0,5,0,0,,,\n"

      expect {
        described_class.new(bad_csv, user_id).call
      }.to raise_error(StandardError)

      expect(Exercise.where(user_id: user_id).count).to eq(0)
      expect(Workout.where(user_id: user_id).count).to eq(0)
    end

    it "scopes exercises to the user" do
      described_class.new(csv_content, user_id).call

      expect(Exercise.where(user_id: user_id).count).to eq(6)
    end
  end
end
