require "rails_helper"

RSpec.describe "Api::V1::Workouts", type: :request do
  let(:headers) { auth_headers }
  let(:other_user_id) { "660e8400-e29b-41d4-a716-446655440000" }
  let(:other_headers) { auth_headers(user_id: other_user_id) }

  let!(:exercise1) { create(:exercise, name: "Bench Press", muscle_group: "chest") }
  let!(:exercise2) { create(:exercise, name: "Squat", muscle_group: "legs") }

  describe "POST /api/v1/workouts" do
    context "starting a blank workout" do
      it "creates an active workout" do
        post "/api/v1/workouts", params: { workout: { name: "Quick Session" } }, headers: headers

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Quick Session")
        expect(body["status"]).to eq("active")
        expect(body["started_at"]).to be_present
        expect(body["workout_exercises"]).to eq([])
      end

      it "returns 422 without a name" do
        post "/api/v1/workouts", params: { workout: { name: "" } }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 401 without auth" do
        post "/api/v1/workouts", params: { workout: { name: "No Auth" } }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "starting from a template" do
      let!(:template) do
        t = create(:workout_template, name: "Push Day")
        create(:template_exercise, workout_template: t, exercise: exercise1,
               position: 1, default_sets: 4, default_reps: 8, default_weight: 135.0, rest_seconds: 90)
        create(:template_exercise, workout_template: t, exercise: exercise2,
               position: 2, default_sets: 3, default_reps: 10, default_weight: 225.0, rest_seconds: 120)
        t
      end

      it "creates a workout with exercises and pre-filled sets" do
        post "/api/v1/workouts", params: { template_id: template.id }, headers: headers

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Push Day")
        expect(body["status"]).to eq("active")
        expect(body["workout_template_id"]).to eq(template.id)
        expect(body["workout_exercises"].length).to eq(2)

        bench = body["workout_exercises"].find { |e| e["exercise_name"] == "Bench Press" }
        expect(bench["position"]).to eq(1)
        expect(bench["rest_seconds"]).to eq(90)
        expect(bench["workout_sets"].length).to eq(4)
        expect(bench["workout_sets"][0]["weight"]).to eq("135.0")
        expect(bench["workout_sets"][0]["reps"]).to eq(8)
        expect(bench["workout_sets"][0]["completed"]).to be false

        squat = body["workout_exercises"].find { |e| e["exercise_name"] == "Squat" }
        expect(squat["workout_sets"].length).to eq(3)
      end

      it "allows overriding the workout name" do
        post "/api/v1/workouts",
             params: { template_id: template.id, workout: { name: "Morning Push" } },
             headers: headers

        body = JSON.parse(response.body)
        expect(body["name"]).to eq("Morning Push")
      end

      it "returns 422 for non-existent template" do
        post "/api/v1/workouts", params: { template_id: 99999 }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 for another user's template" do
        other_template = create(:workout_template, name: "Other", user_id: other_user_id)

        post "/api/v1/workouts", params: { template_id: other_template.id }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /api/v1/workouts" do
    before do
      create(:workout, :completed, name: "Workout A", started_at: 3.days.ago)
      create(:workout, :completed, name: "Workout B", started_at: 1.day.ago)
      create(:workout, name: "Active One", started_at: Time.current)
    end

    it "returns workouts sorted by started_at desc" do
      get "/api/v1/workouts", headers: headers

      body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(body.length).to eq(3)
      expect(body[0]["name"]).to eq("Active One")
      expect(body[1]["name"]).to eq("Workout B")
    end

    it "includes exercise and set counts" do
      workout = Workout.find_by(name: "Workout A")
      we = create(:workout_exercise, workout: workout, exercise: exercise1)
      create(:workout_set, workout_exercise: we)
      create(:workout_set, workout_exercise: we)

      get "/api/v1/workouts", headers: headers

      body = JSON.parse(response.body)
      a = body.find { |w| w["name"] == "Workout A" }
      expect(a["exercise_count"]).to eq(1)
      expect(a["set_count"]).to eq(2)
    end

    it "filters by status" do
      get "/api/v1/workouts", params: { status: "completed" }, headers: headers

      body = JSON.parse(response.body)
      expect(body.length).to eq(2)
      expect(body.all? { |w| w["status"] == "completed" }).to be true
    end

    it "filters by date range" do
      get "/api/v1/workouts",
          params: { start_date: 2.days.ago.to_date.iso8601, end_date: Date.current.iso8601 },
          headers: headers

      body = JSON.parse(response.body)
      expect(body.length).to eq(2)
    end

    it "does not return other user's workouts" do
      create(:workout, name: "Secret", user_id: other_user_id)

      get "/api/v1/workouts", headers: headers

      body = JSON.parse(response.body)
      expect(body.none? { |w| w["name"] == "Secret" }).to be true
    end

    it "paginates results" do
      get "/api/v1/workouts", params: { page: 1, per_page: 2 }, headers: headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.length).to eq(2)
    end
  end

  describe "GET /api/v1/workouts/calendar" do
    it "returns completed workout dates for a month" do
      create(:workout, :completed, name: "Day 1", started_at: Date.new(2024, 8, 5).beginning_of_day)
      create(:workout, :completed, name: "Day 2", started_at: Date.new(2024, 8, 12).beginning_of_day)
      create(:workout, name: "Active", started_at: Date.new(2024, 8, 20).beginning_of_day)

      get "/api/v1/workouts/calendar", params: { year: 2024, month: 8 }, headers: headers

      body = JSON.parse(response.body)
      expect(body.length).to eq(2)
      expect(body[0]["date"]).to eq("2024-08-05")
      expect(body[0]["workout_name"]).to eq("Day 1")
      expect(body[0]["workout_id"]).to be_present
    end

    it "returns empty array for month with no workouts" do
      get "/api/v1/workouts/calendar", params: { year: 2020, month: 1 }, headers: headers

      body = JSON.parse(response.body)
      expect(body).to eq([])
    end
  end

  describe "GET /api/v1/workouts/:id" do
    it "returns the full workout tree" do
      workout = create(:workout, name: "Full Workout")
      we = create(:workout_exercise, workout: workout, exercise: exercise1, position: 1)
      create(:workout_set, workout_exercise: we, set_order: 1, weight: 135, reps: 8)
      create(:workout_set, workout_exercise: we, set_order: 2, weight: 135, reps: 6)

      get "/api/v1/workouts/#{workout.id}", headers: headers

      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Full Workout")
      expect(body["workout_exercises"].length).to eq(1)
      expect(body["workout_exercises"][0]["exercise_name"]).to eq("Bench Press")
      expect(body["workout_exercises"][0]["workout_sets"].length).to eq(2)
      expect(body["workout_exercises"][0]["workout_sets"][0]["weight"]).to eq("135.0")
    end

    it "returns 404 for another user's workout" do
      other_workout = create(:workout, user_id: other_user_id)

      get "/api/v1/workouts/#{other_workout.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for non-existent workout" do
      get "/api/v1/workouts/99999", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /api/v1/workouts/:id" do
    let!(:workout) { create(:workout, name: "My Workout") }

    it "completes a workout" do
      patch "/api/v1/workouts/#{workout.id}", params: { status: "completed" }, headers: headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["status"]).to eq("completed")
      expect(body["completed_at"]).to be_present
      expect(body["duration_seconds"]).to be_present
    end

    it "cancels a workout" do
      patch "/api/v1/workouts/#{workout.id}", params: { status: "cancelled" }, headers: headers

      body = JSON.parse(response.body)
      expect(body["status"]).to eq("cancelled")
      expect(body["completed_at"]).to be_present
    end

    it "updates workout name and notes" do
      patch "/api/v1/workouts/#{workout.id}",
            params: { workout: { name: "Renamed", notes: "Great session" } },
            headers: headers

      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Renamed")
      expect(body["notes"]).to eq("Great session")
    end

    it "returns 404 for another user's workout" do
      other_workout = create(:workout, user_id: other_user_id)

      patch "/api/v1/workouts/#{other_workout.id}",
            params: { workout: { name: "Hacked" } }, headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/workouts/:id" do
    it "deletes the workout and its exercises and sets" do
      workout = create(:workout)
      we = create(:workout_exercise, workout: workout, exercise: exercise1)
      create(:workout_set, workout_exercise: we)

      delete "/api/v1/workouts/#{workout.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(Workout.find_by(id: workout.id)).to be_nil
      expect(WorkoutExercise.find_by(id: we.id)).to be_nil
    end

    it "returns 404 for another user's workout" do
      other_workout = create(:workout, user_id: other_user_id)

      delete "/api/v1/workouts/#{other_workout.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end
end
