class DefaultExerciseSeeder
  EXERCISES = [
    # Chest
    { name: "Bench Press (Barbell)", muscle_group: "chest", equipment_type: "barbell",
      description: "Lie on a flat bench, grip the bar slightly wider than shoulder-width. Lower to mid-chest, press back up to lockout." },
    { name: "Incline Bench Press (Barbell)", muscle_group: "chest", equipment_type: "barbell",
      description: "Set bench to 30-45 degrees. Press bar from upper chest to lockout. Targets upper chest." },
    { name: "Bench Press (Dumbbell)", muscle_group: "chest", equipment_type: "dumbbell",
      description: "Lie flat with a dumbbell in each hand at chest level. Press up, bringing dumbbells together at the top." },
    { name: "Incline Bench Press (Dumbbell)", muscle_group: "chest", equipment_type: "dumbbell",
      description: "Set bench to 30-45 degrees. Press dumbbells from upper chest to lockout. Greater range of motion than barbell." },
    { name: "Chest Fly (Dumbbell)", muscle_group: "chest", equipment_type: "dumbbell",
      description: "Lie flat with arms extended above chest. Lower dumbbells in a wide arc with a slight elbow bend, then squeeze back together." },
    { name: "Cable Crossover", muscle_group: "chest", equipment_type: "cable",
      description: "Stand between cable pulleys set high. Pull handles down and together in a hugging motion. Squeeze at the bottom." },
    { name: "Chest Dip", muscle_group: "chest", equipment_type: "bodyweight",
      description: "Lean forward on parallel bars. Lower until upper arms are parallel to the ground, then press back up." },
    { name: "Pec Deck (Machine)", muscle_group: "chest", equipment_type: "machine",
      description: "Sit with arms on padded levers at chest height. Squeeze arms together in front of chest, then slowly release." },

    # Back
    { name: "Deadlift (Barbell)", muscle_group: "back", equipment_type: "barbell",
      description: "Stand over bar with feet hip-width. Hinge at hips, grip bar, drive through feet to stand. Keep back flat throughout." },
    { name: "Bent Over Row (Barbell)", muscle_group: "back", equipment_type: "barbell",
      description: "Hinge forward at hips, back flat. Pull bar to lower chest/upper belly. Squeeze shoulder blades together at top." },
    { name: "Bent Over Row (Dumbbell)", muscle_group: "back", equipment_type: "dumbbell",
      description: "One knee and hand on bench, row dumbbell to hip with opposite arm. Keep elbow close to body." },
    { name: "Lat Pulldown (Cable)", muscle_group: "back", equipment_type: "cable",
      description: "Sit at lat pulldown station, grip bar wide. Pull bar to upper chest, squeezing lats. Control the return." },
    { name: "Seated Row (Cable)", muscle_group: "back", equipment_type: "cable",
      description: "Sit upright, pull handle to lower chest. Keep elbows close to body, squeeze shoulder blades together." },
    { name: "Pull Up", muscle_group: "back", equipment_type: "bodyweight",
      description: "Hang from bar with overhand grip. Pull chin above bar by driving elbows down. Lower with control." },
    { name: "T-Bar Row", muscle_group: "back", equipment_type: "barbell",
      description: "Straddle the bar, grip the handle. Row the weight up to chest keeping back flat. Squeeze at the top." },

    # Shoulders
    { name: "Overhead Press (Barbell)", muscle_group: "shoulders", equipment_type: "barbell",
      description: "Standing or seated, press bar from front of shoulders to overhead lockout. Keep core tight." },
    { name: "Shoulder Press (Dumbbell)", muscle_group: "shoulders", equipment_type: "dumbbell",
      description: "Seated or standing, press dumbbells from shoulder height to overhead. Palms face forward." },
    { name: "Lateral Raise (Dumbbell)", muscle_group: "shoulders", equipment_type: "dumbbell",
      description: "Stand with dumbbells at sides. Raise arms out to sides until parallel with floor. Control the descent." },
    { name: "Lateral Raise (Cable)", muscle_group: "shoulders", equipment_type: "cable",
      description: "Stand sideways to cable set low. Raise arm out to side until parallel with floor. Constant tension throughout." },
    { name: "Front Raise (Dumbbell)", muscle_group: "shoulders", equipment_type: "dumbbell",
      description: "Stand with dumbbells at thighs. Raise one or both arms forward to shoulder height. Lower with control." },
    { name: "Reverse Fly (Dumbbell)", muscle_group: "shoulders", equipment_type: "dumbbell",
      description: "Bend forward at hips. Raise dumbbells out to sides, squeezing rear delts. Targets posterior deltoids." },
    { name: "Face Pull (Cable)", muscle_group: "shoulders", equipment_type: "cable",
      description: "Set cable at face height with rope. Pull toward face, spreading rope apart. Squeeze rear delts and rotator cuffs." },
    { name: "Shrug (Dumbbell)", muscle_group: "shoulders", equipment_type: "dumbbell",
      description: "Hold dumbbells at sides. Shrug shoulders straight up toward ears. Hold briefly at top, lower slowly." },

    # Arms
    { name: "Bicep Curl (Barbell)", muscle_group: "arms", equipment_type: "barbell",
      description: "Stand with barbell at arm's length. Curl bar up to shoulders, keeping elbows pinned at sides." },
    { name: "Bicep Curl (Dumbbell)", muscle_group: "arms", equipment_type: "dumbbell",
      description: "Curl dumbbells from thighs to shoulders, alternating or together. Keep elbows stationary." },
    { name: "Hammer Curl (Dumbbell)", muscle_group: "arms", equipment_type: "dumbbell",
      description: "Curl with palms facing each other (neutral grip). Targets brachialis and forearms in addition to biceps." },
    { name: "Preacher Curl (Dumbbell)", muscle_group: "arms", equipment_type: "dumbbell",
      description: "Rest upper arms on preacher bench pad. Curl weight up, fully extending at the bottom for a deep stretch." },
    { name: "Triceps Pushdown (Cable)", muscle_group: "arms", equipment_type: "cable",
      description: "Stand at cable with bar or rope attached high. Push down until arms are straight. Keep elbows at sides." },
    { name: "Triceps Extension (Cable)", muscle_group: "arms", equipment_type: "cable",
      description: "Face away from cable set high. Extend arms overhead, keeping upper arms still. Targets long head of triceps." },
    { name: "Skullcrusher (Barbell)", muscle_group: "arms", equipment_type: "barbell",
      description: "Lie on bench, lower bar to forehead by bending elbows. Extend back up. Keep upper arms vertical." },
    { name: "Triceps Dip", muscle_group: "arms", equipment_type: "bodyweight",
      description: "Support yourself on parallel bars, body upright. Lower until elbows reach 90 degrees, press back up." },

    # Legs
    { name: "Squat (Barbell)", muscle_group: "legs", equipment_type: "barbell",
      description: "Bar on upper back, feet shoulder-width. Squat to parallel or below, drive through heels to stand." },
    { name: "Romanian Deadlift (Barbell)", muscle_group: "legs", equipment_type: "barbell",
      description: "Hold bar at hip level. Hinge at hips, sliding bar down legs. Feel hamstring stretch, then drive hips forward." },
    { name: "Leg Press (Machine)", muscle_group: "legs", equipment_type: "machine",
      description: "Sit in leg press, feet shoulder-width on platform. Lower platform by bending knees, press back to start." },
    { name: "Leg Extension (Machine)", muscle_group: "legs", equipment_type: "machine",
      description: "Sit with shins behind pad. Extend legs until straight, squeezing quads at the top. Lower with control." },
    { name: "Leg Curl (Machine)", muscle_group: "legs", equipment_type: "machine",
      description: "Lie face down or sit with ankles over pad. Curl weight by bending knees. Targets hamstrings." },
    { name: "Bulgarian Split Squat", muscle_group: "legs", equipment_type: "bodyweight",
      description: "Rear foot elevated on bench. Lower front thigh to parallel by bending front knee. Drive up through front heel." },
    { name: "Lunge (Dumbbell)", muscle_group: "legs", equipment_type: "dumbbell",
      description: "Step forward into a lunge, both knees at 90 degrees. Push back to standing. Alternate legs." },
    { name: "Hip Thrust (Barbell)", muscle_group: "legs", equipment_type: "barbell",
      description: "Upper back on bench, bar across hips. Drive hips up until body is straight. Squeeze glutes at top." },
    { name: "Calf Raise (Machine)", muscle_group: "legs", equipment_type: "machine",
      description: "Stand on platform edge with shoulders under pads. Rise up on toes, pause at top, lower until calves stretch." },

    # Abs
    { name: "Crunch", muscle_group: "abs", equipment_type: "bodyweight",
      description: "Lie on back, knees bent. Curl shoulders off floor toward knees. Focus on contracting the abs, not pulling neck." },
    { name: "Hanging Leg Raise", muscle_group: "abs", equipment_type: "bodyweight",
      description: "Hang from pull-up bar. Raise legs to parallel or higher while keeping them straight. Lower with control." },
    { name: "Cable Crunch", muscle_group: "abs", equipment_type: "cable",
      description: "Kneel facing cable with rope behind head. Crunch down, driving elbows toward knees. Resist on the way up." },
    { name: "Plank", muscle_group: "abs", equipment_type: "bodyweight",
      description: "Hold push-up position on forearms. Keep body in a straight line from head to heels. Brace core throughout." },

    # Forearms
    { name: "Wrist Curl (Barbell)", muscle_group: "forearms", equipment_type: "barbell",
      description: "Sit with forearms on thighs, palms up, wrists over knees. Curl bar up using only wrist movement." },
    { name: "Reverse Curl (Barbell)", muscle_group: "forearms", equipment_type: "barbell",
      description: "Curl barbell with overhand (pronated) grip. Targets brachioradialis and forearm extensors." }
  ].freeze

  def initialize(user_id)
    @user_id = user_id
  end

  def call
    created = 0
    EXERCISES.each do |attrs|
      exercise = Exercise.find_or_initialize_by(user_id: @user_id, name: attrs[:name])
      if exercise.new_record?
        exercise.assign_attributes(attrs.merge(is_default: true))
        exercise.save!
        created += 1
      end
    end
    created
  end
end
