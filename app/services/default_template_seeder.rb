class DefaultTemplateSeeder
  TEMPLATES = [
    {
      name: "Push Day",
      notes: "Chest, shoulders, and triceps",
      exercises: [
        { name: "Bench Press (Barbell)", default_sets: 4, default_reps: 8, rest_seconds: 120 },
        { name: "Incline Bench Press (Dumbbell)", default_sets: 3, default_reps: 10, rest_seconds: 90 },
        { name: "Shoulder Press (Dumbbell)", default_sets: 3, default_reps: 10, rest_seconds: 90 },
        { name: "Lateral Raise (Dumbbell)", default_sets: 3, default_reps: 12, rest_seconds: 60 },
        { name: "Triceps Pushdown (Cable)", default_sets: 3, default_reps: 12, rest_seconds: 60 },
        { name: "Chest Fly (Dumbbell)", default_sets: 3, default_reps: 12, rest_seconds: 60 }
      ]
    },
    {
      name: "Pull Day",
      notes: "Back and biceps",
      exercises: [
        { name: "Deadlift (Barbell)", default_sets: 3, default_reps: 5, rest_seconds: 180 },
        { name: "Bent Over Row (Barbell)", default_sets: 4, default_reps: 8, rest_seconds: 120 },
        { name: "Lat Pulldown (Cable)", default_sets: 3, default_reps: 10, rest_seconds: 90 },
        { name: "Seated Row (Cable)", default_sets: 3, default_reps: 10, rest_seconds: 90 },
        { name: "Bicep Curl (Dumbbell)", default_sets: 3, default_reps: 12, rest_seconds: 60 },
        { name: "Face Pull (Cable)", default_sets: 3, default_reps: 15, rest_seconds: 60 }
      ]
    },
    {
      name: "Leg Day",
      notes: "Quads, hamstrings, glutes, and calves",
      exercises: [
        { name: "Squat (Barbell)", default_sets: 4, default_reps: 8, rest_seconds: 150 },
        { name: "Romanian Deadlift (Barbell)", default_sets: 3, default_reps: 10, rest_seconds: 120 },
        { name: "Leg Press (Machine)", default_sets: 3, default_reps: 12, rest_seconds: 90 },
        { name: "Leg Extension (Machine)", default_sets: 3, default_reps: 12, rest_seconds: 60 },
        { name: "Leg Curl (Machine)", default_sets: 3, default_reps: 12, rest_seconds: 60 },
        { name: "Calf Raise (Machine)", default_sets: 4, default_reps: 15, rest_seconds: 60 }
      ]
    }
  ].freeze

  def initialize(user_id)
    @user_id = user_id
  end

  def call
    now = Time.current

    template_records = TEMPLATES.map do |t|
      { user_id: @user_id, name: t[:name], notes: t[:notes], is_default: true, created_at: now, updated_at: now }
    end
    WorkoutTemplate.insert_all!(template_records)

    templates = WorkoutTemplate.where(user_id: @user_id, is_default: true).index_by(&:name)
    exercises = Exercise.where(user_id: @user_id).index_by(&:name)

    te_records = []
    TEMPLATES.each do |template_def|
      template = templates[template_def[:name]]
      next unless template

      template_def[:exercises].each_with_index do |ex_def, idx|
        exercise = exercises[ex_def[:name]]
        next unless exercise

        te_records << {
          workout_template_id: template.id,
          exercise_id: exercise.id,
          position: idx + 1,
          default_sets: ex_def[:default_sets],
          default_reps: ex_def[:default_reps],
          rest_seconds: ex_def[:rest_seconds],
          created_at: now,
          updated_at: now
        }
      end
    end
    TemplateExercise.insert_all!(te_records) if te_records.any?

    TEMPLATES.size
  end
end
