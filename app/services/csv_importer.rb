require "csv"

class CsvImporter
  EQUIPMENT_MAP = {
    "barbell" => "barbell",
    "dumbbell" => "dumbbell",
    "cable" => "cable",
    "machine" => "machine",
    "smith machine" => "smith_machine",
    "assisted" => "bodyweight",
    "cable - straight bar" => "cable"
  }.freeze

  Result = Struct.new(:exercises_created, :workouts_created, :sets_created, keyword_init: true)

  def initialize(csv_content, user_id)
    @csv_content = csv_content
    @user_id = user_id
  end

  def call
    rows = CSV.parse(@csv_content, headers: true)

    raise CSV::MalformedCSVError.new("File exceeds maximum of 50,000 rows", 0) if rows.size > 50_000

    exercises_created = 0
    workouts_created = 0
    sets_created = 0

    ActiveRecord::Base.transaction do
      exercise_cache = create_exercises(rows)
      exercises_created = exercise_cache.size

      sessions = group_sessions(rows)

      sessions.each do |(_date, _name), session_rows|
        first_row = session_rows.first
        duration = parse_duration(first_row["Duration"])
        started_at = Time.zone.parse(first_row["Date"])

        workout = Workout.create!(
          user_id: @user_id,
          name: first_row["Workout Name"].strip,
          started_at: started_at,
          completed_at: started_at + (duration || 0).seconds,
          duration_seconds: duration,
          status: "completed",
          notes: first_row["Workout Notes"].presence
        )
        workouts_created += 1

        exercise_groups = session_rows.group_by { |r| r["Exercise Name"].strip }

        exercise_groups.each_with_index do |(exercise_name, set_rows), position|
          exercise = exercise_cache[exercise_name]

          workout_exercise = WorkoutExercise.create!(
            workout: workout,
            exercise: exercise,
            position: position + 1
          )

          set_rows.each do |row|
            weight = row["Weight"].to_f
            weight = weight.round(2)
            reps = row["Reps"].to_i
            distance_val = row["Distance"].to_f
            seconds_val = row["Seconds"].to_i
            rpe_val = parse_rpe(row["RPE"])

            WorkoutSet.create!(
              workout_exercise: workout_exercise,
              set_order: [ row["Set Order"].to_i, 1 ].max,
              weight: weight > 0 ? weight : nil,
              reps: reps > 0 ? reps : nil,
              distance: distance_val > 0 ? distance_val : nil,
              duration_seconds: seconds_val > 0 ? seconds_val : nil,
              rpe: rpe_val,
              completed: true,
              completed_at: Time.zone.parse(row["Date"]),
              notes: row["Notes"].presence
            )
            sets_created += 1
          end
        end
      end
    end

    Result.new(exercises_created: exercises_created, workouts_created: workouts_created, sets_created: sets_created)
  end

  private

  def create_exercises(rows)
    cache = {}
    unique_names = rows.map { |r| r["Exercise Name"].strip }.uniq

    unique_names.each do |name|
      equipment = infer_equipment(name)
      exercise = Exercise.create!(
        user_id: @user_id,
        name: name,
        equipment_type: equipment
      )
      cache[name] = exercise
    end

    cache
  end

  def group_sessions(rows)
    rows.group_by { |r| [ r["Date"], r["Workout Name"].strip ] }
  end

  def infer_equipment(name)
    match = name.match(/\(([^)]+)\)\s*$/)
    return nil unless match

    descriptor = match[1].downcase.strip
    EQUIPMENT_MAP[descriptor]
  end

  def parse_duration(str)
    return nil if str.blank?

    str = str.strip
    total = 0

    if str.match?(/\A\d+s\z/)
      return str.to_i
    end

    hours = str.match(/(\d+)h/)
    minutes = str.match(/(\d+)\s*min/)

    total += hours[1].to_i * 3600 if hours
    total += minutes[1].to_i * 60 if minutes

    total > 0 ? total : nil
  end

  def parse_rpe(val)
    return nil if val.blank?
    cleaned = val.to_s.strip
    return nil if cleaned.empty?
    float_val = cleaned.to_f
    float_val > 0 && float_val <= 10 ? float_val : nil
  end
end
