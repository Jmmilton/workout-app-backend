require "rails_helper"

RSpec.describe "Api::V1::Exercises", type: :request do
  let(:user_id) { AuthHelpers::TEST_USER_ID }
  let(:other_user_id) { "660e8400-e29b-41d4-a716-446655440000" }

  describe "GET /api/v1/exercises" do
    it "returns exercises for the authenticated user" do
      create(:exercise, user_id: user_id, name: "Bench Press")
      create(:exercise, user_id: user_id, name: "Squat")
      create(:exercise, user_id: other_user_id, name: "Other User Exercise")

      get "/api/v1/exercises", headers: auth_headers
      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body.length).to eq(2)
      names = body.map { |e| e["name"] }
      expect(names).to contain_exactly("Bench Press", "Squat")
    end

    it "returns exercises sorted by name" do
      create(:exercise, user_id: user_id, name: "Squat")
      create(:exercise, user_id: user_id, name: "Bench Press")
      create(:exercise, user_id: user_id, name: "Deadlift")

      get "/api/v1/exercises", headers: auth_headers
      body = JSON.parse(response.body)
      names = body.map { |e| e["name"] }
      expect(names).to eq(["Bench Press", "Deadlift", "Squat"])
    end

    it "filters by muscle_group" do
      create(:exercise, user_id: user_id, name: "Bench Press", muscle_group: "chest")
      create(:exercise, user_id: user_id, name: "Squat", muscle_group: "legs")

      get "/api/v1/exercises", params: { muscle_group: "chest" }, headers: auth_headers
      body = JSON.parse(response.body)
      expect(body.length).to eq(1)
      expect(body[0]["name"]).to eq("Bench Press")
    end

    it "filters by equipment_type" do
      create(:exercise, user_id: user_id, name: "Bench Press", equipment_type: "barbell")
      create(:exercise, user_id: user_id, name: "Cable Fly", equipment_type: "cable")

      get "/api/v1/exercises", params: { equipment_type: "cable" }, headers: auth_headers
      body = JSON.parse(response.body)
      expect(body.length).to eq(1)
      expect(body[0]["name"]).to eq("Cable Fly")
    end

    it "returns 401 without authentication" do
      get "/api/v1/exercises"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/exercises/:id" do
    it "returns the exercise" do
      exercise = create(:exercise, user_id: user_id, name: "Bench Press")

      get "/api/v1/exercises/#{exercise.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Bench Press")
      expect(body["id"]).to eq(exercise.id)
    end

    it "returns 404 for another user's exercise" do
      exercise = create(:exercise, user_id: other_user_id, name: "Other Exercise")

      get "/api/v1/exercises/#{exercise.id}", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for non-existent exercise" do
      get "/api/v1/exercises/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/exercises" do
    it "creates an exercise" do
      params = { exercise: { name: "Bench Press", muscle_group: "chest", equipment_type: "barbell" } }

      post "/api/v1/exercises", params: params, headers: auth_headers
      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Bench Press")
      expect(body["muscle_group"]).to eq("chest")
      expect(body["equipment_type"]).to eq("barbell")
    end

    it "returns 422 for missing name" do
      params = { exercise: { muscle_group: "chest" } }

      post "/api/v1/exercises", params: params, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Name can't be blank")
    end

    it "returns 422 for duplicate name (same user)" do
      create(:exercise, user_id: user_id, name: "Bench Press")
      params = { exercise: { name: "Bench Press" } }

      post "/api/v1/exercises", params: params, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Name has already been taken")
    end

    it "allows duplicate name for different users" do
      create(:exercise, user_id: other_user_id, name: "Bench Press")
      params = { exercise: { name: "Bench Press", muscle_group: "chest" } }

      post "/api/v1/exercises", params: params, headers: auth_headers
      expect(response).to have_http_status(:created)
    end

    it "returns 422 for invalid muscle_group" do
      params = { exercise: { name: "Test", muscle_group: "invalid" } }

      post "/api/v1/exercises", params: params, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/exercises/:id" do
    it "updates the exercise" do
      exercise = create(:exercise, user_id: user_id, name: "Bench Press")
      params = { exercise: { name: "Incline Bench Press" } }

      patch "/api/v1/exercises/#{exercise.id}", params: params, headers: auth_headers
      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Incline Bench Press")
    end

    it "returns 404 for another user's exercise" do
      exercise = create(:exercise, user_id: other_user_id)
      params = { exercise: { name: "Hacked" } }

      patch "/api/v1/exercises/#{exercise.id}", params: params, headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns 422 for invalid update" do
      exercise = create(:exercise, user_id: user_id, name: "Bench Press")
      params = { exercise: { name: "" } }

      patch "/api/v1/exercises/#{exercise.id}", params: params, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/exercises/:id" do
    it "deletes the exercise" do
      exercise = create(:exercise, user_id: user_id, name: "Bench Press")

      delete "/api/v1/exercises/#{exercise.id}", headers: auth_headers
      expect(response).to have_http_status(:no_content)

      expect(Exercise.find_by(id: exercise.id)).to be_nil
    end

    it "returns 404 for another user's exercise" do
      exercise = create(:exercise, user_id: other_user_id)

      delete "/api/v1/exercises/#{exercise.id}", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns 422 when exercise has dependent template_exercises" do
      exercise = create(:exercise, user_id: user_id)
      template = create(:workout_template, user_id: user_id)
      create(:template_exercise, exercise: exercise, workout_template: template)

      delete "/api/v1/exercises/#{exercise.id}", headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
