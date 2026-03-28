require "rails_helper"

RSpec.describe "Api::V1::WorkoutExercises", type: :request do
  let(:headers) { auth_headers }
  let(:other_user_id) { "660e8400-e29b-41d4-a716-446655440000" }
  let!(:exercise) { create(:exercise, name: "Bench Press", muscle_group: "chest") }
  let!(:exercise2) { create(:exercise, name: "Squat", muscle_group: "legs") }
  let!(:workout) { create(:workout, name: "Test Workout") }

  describe "POST /api/v1/workouts/:workout_id/exercises" do
    it "adds an exercise to the workout with default sets" do
      post "/api/v1/workouts/#{workout.id}/exercises",
           params: { workout_exercise: { exercise_id: exercise.id } },
           headers: headers

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["exercise_name"]).to eq("Bench Press")
      expect(body["position"]).to eq(1)
      expect(body["rest_seconds"]).to eq(90)
      expect(body["workout_sets"].length).to eq(3)
      expect(body["workout_sets"][0]["set_order"]).to eq(1)
    end

    it "auto-increments position" do
      create(:workout_exercise, workout: workout, exercise: exercise, position: 1)

      post "/api/v1/workouts/#{workout.id}/exercises",
           params: { workout_exercise: { exercise_id: exercise2.id } },
           headers: headers

      body = JSON.parse(response.body)
      expect(body["position"]).to eq(2)
    end

    it "allows custom sets count" do
      post "/api/v1/workouts/#{workout.id}/exercises",
           params: { workout_exercise: { exercise_id: exercise.id, sets_count: 5 } },
           headers: headers

      body = JSON.parse(response.body)
      expect(body["workout_sets"].length).to eq(5)
    end

    it "allows custom rest seconds" do
      post "/api/v1/workouts/#{workout.id}/exercises",
           params: { workout_exercise: { exercise_id: exercise.id, rest_seconds: 120 } },
           headers: headers

      body = JSON.parse(response.body)
      expect(body["rest_seconds"]).to eq(120)
    end

    it "returns 404 for another user's workout" do
      other_workout = create(:workout, user_id: other_user_id)

      post "/api/v1/workouts/#{other_workout.id}/exercises",
           params: { workout_exercise: { exercise_id: exercise.id } },
           headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /api/v1/workouts/:workout_id/exercises/:id" do
    let!(:we) { create(:workout_exercise, workout: workout, exercise: exercise, position: 1, rest_seconds: 90) }

    it "updates rest seconds" do
      patch "/api/v1/workouts/#{workout.id}/exercises/#{we.id}",
            params: { workout_exercise: { rest_seconds: 120 } },
            headers: headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["rest_seconds"]).to eq(120)
    end

    it "updates notes" do
      patch "/api/v1/workouts/#{workout.id}/exercises/#{we.id}",
            params: { workout_exercise: { notes: "Go heavy" } },
            headers: headers

      body = JSON.parse(response.body)
      expect(body["notes"]).to eq("Go heavy")
    end
  end

  describe "DELETE /api/v1/workouts/:workout_id/exercises/:id" do
    it "removes the exercise and its sets" do
      we = create(:workout_exercise, workout: workout, exercise: exercise)
      set = create(:workout_set, workout_exercise: we)

      delete "/api/v1/workouts/#{workout.id}/exercises/#{we.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(WorkoutExercise.find_by(id: we.id)).to be_nil
      expect(WorkoutSet.find_by(id: set.id)).to be_nil
    end

    it "returns 404 for exercise not in this workout" do
      other_workout = create(:workout)
      we = create(:workout_exercise, workout: other_workout, exercise: exercise)

      delete "/api/v1/workouts/#{workout.id}/exercises/#{we.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end
end
