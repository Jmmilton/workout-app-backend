require "rails_helper"

RSpec.describe "Api::V1::WorkoutSets", type: :request do
  let(:headers) { auth_headers }
  let(:other_user_id) { "660e8400-e29b-41d4-a716-446655440000" }
  let!(:exercise) { create(:exercise, name: "Bench Press") }
  let!(:workout) { create(:workout, name: "Test Workout") }
  let!(:we) { create(:workout_exercise, workout: workout, exercise: exercise, position: 1) }

  describe "POST /api/v1/workouts/:workout_id/exercises/:exercise_id/sets" do
    it "creates a new set with auto-incremented order" do
      create(:workout_set, workout_exercise: we, set_order: 1)

      post "/api/v1/workouts/#{workout.id}/exercises/#{we.id}/sets",
           params: { workout_set: { weight: 140, reps: 6 } },
           headers: headers

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["set_order"]).to eq(2)
      expect(body["weight"]).to eq("140.0")
      expect(body["reps"]).to eq(6)
      expect(body["completed"]).to be false
    end

    it "creates a set with no weight or reps" do
      post "/api/v1/workouts/#{workout.id}/exercises/#{we.id}/sets",
           headers: headers

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["set_order"]).to eq(1)
      expect(body["weight"]).to be_nil
      expect(body["reps"]).to be_nil
    end

    it "returns 404 for another user's workout" do
      other_workout = create(:workout, user_id: other_user_id)
      other_we = create(:workout_exercise, workout: other_workout, exercise: exercise)

      post "/api/v1/workouts/#{other_workout.id}/exercises/#{other_we.id}/sets",
           params: { workout_set: { weight: 100 } },
           headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /api/v1/workouts/:workout_id/exercises/:exercise_id/sets/:id" do
    let!(:workout_set) { create(:workout_set, workout_exercise: we, set_order: 1, weight: 100, reps: 8) }

    it "updates weight and reps" do
      patch "/api/v1/workouts/#{workout.id}/exercises/#{we.id}/sets/#{workout_set.id}",
            params: { workout_set: { weight: 120, reps: 6 } },
            headers: headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["weight"]).to eq("120.0")
      expect(body["reps"]).to eq(6)
    end

    it "marks set as completed with timestamp" do
      patch "/api/v1/workouts/#{workout.id}/exercises/#{we.id}/sets/#{workout_set.id}",
            params: { workout_set: { completed: true } },
            headers: headers

      body = JSON.parse(response.body)
      expect(body["completed"]).to be true
      expect(body["completed_at"]).to be_present
    end

    it "uncompletes a set" do
      workout_set.complete!

      patch "/api/v1/workouts/#{workout.id}/exercises/#{we.id}/sets/#{workout_set.id}",
            params: { workout_set: { completed: false } },
            headers: headers

      body = JSON.parse(response.body)
      expect(body["completed"]).to be false
      expect(body["completed_at"]).to be_nil
    end

    it "updates RPE" do
      patch "/api/v1/workouts/#{workout.id}/exercises/#{we.id}/sets/#{workout_set.id}",
            params: { workout_set: { rpe: 8.5 } },
            headers: headers

      body = JSON.parse(response.body)
      expect(body["rpe"]).to eq("8.5")
    end

    it "returns 404 for set not in this exercise" do
      other_we = create(:workout_exercise, workout: workout, exercise: exercise, position: 2)
      other_set = create(:workout_set, workout_exercise: other_we)

      patch "/api/v1/workouts/#{workout.id}/exercises/#{we.id}/sets/#{other_set.id}",
            params: { workout_set: { weight: 999 } },
            headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/workouts/:workout_id/exercises/:exercise_id/sets/:id" do
    it "deletes the set" do
      workout_set = create(:workout_set, workout_exercise: we)

      delete "/api/v1/workouts/#{workout.id}/exercises/#{we.id}/sets/#{workout_set.id}",
             headers: headers

      expect(response).to have_http_status(:no_content)
      expect(WorkoutSet.find_by(id: workout_set.id)).to be_nil
    end

    it "returns 404 for set not in this exercise" do
      other_we = create(:workout_exercise, workout: workout, exercise: exercise, position: 2)
      other_set = create(:workout_set, workout_exercise: other_we)

      delete "/api/v1/workouts/#{workout.id}/exercises/#{we.id}/sets/#{other_set.id}",
             headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end
end
