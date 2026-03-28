require "rails_helper"

RSpec.describe "Api::V1::WorkoutTemplates", type: :request do
  let(:user_id) { AuthHelpers::TEST_USER_ID }
  let(:other_user_id) { "660e8400-e29b-41d4-a716-446655440000" }

  describe "GET /api/v1/workout_templates" do
    it "returns templates for the authenticated user" do
      create(:workout_template, user_id: user_id, name: "Push Day")
      create(:workout_template, user_id: user_id, name: "Pull Day")
      create(:workout_template, user_id: other_user_id, name: "Other User Template")

      get "/api/v1/workout_templates", headers: auth_headers
      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body.length).to eq(2)
      names = body.map { |t| t["name"] }
      expect(names).to contain_exactly("Push Day", "Pull Day")
    end

    it "returns templates sorted by name" do
      create(:workout_template, user_id: user_id, name: "Push Day")
      create(:workout_template, user_id: user_id, name: "Leg Day")
      create(:workout_template, user_id: user_id, name: "Pull Day")

      get "/api/v1/workout_templates", headers: auth_headers
      body = JSON.parse(response.body)
      names = body.map { |t| t["name"] }
      expect(names).to eq(["Leg Day", "Pull Day", "Push Day"])
    end

    it "includes nested template_exercises with exercise details" do
      template = create(:workout_template, user_id: user_id, name: "Push Day")
      exercise = create(:exercise, user_id: user_id, name: "Bench Press", muscle_group: "chest", equipment_type: "barbell")
      create(:template_exercise, workout_template: template, exercise: exercise, position: 1, default_sets: 4, default_reps: 8, default_weight: 135.0, rest_seconds: 90)

      get "/api/v1/workout_templates", headers: auth_headers
      body = JSON.parse(response.body)

      te = body[0]["template_exercises"]
      expect(te.length).to eq(1)
      expect(te[0]["exercise_name"]).to eq("Bench Press")
      expect(te[0]["muscle_group"]).to eq("chest")
      expect(te[0]["equipment_type"]).to eq("barbell")
      expect(te[0]["default_sets"]).to eq(4)
      expect(te[0]["default_reps"]).to eq(8)
      expect(te[0]["default_weight"]).to eq("135.0")
      expect(te[0]["rest_seconds"]).to eq(90)
    end

    it "returns 401 without authentication" do
      get "/api/v1/workout_templates"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/workout_templates/:id" do
    it "returns the template with nested exercises" do
      template = create(:workout_template, user_id: user_id, name: "Push Day")
      ex1 = create(:exercise, user_id: user_id, name: "Bench Press")
      ex2 = create(:exercise, user_id: user_id, name: "Overhead Press")
      create(:template_exercise, workout_template: template, exercise: ex1, position: 1)
      create(:template_exercise, workout_template: template, exercise: ex2, position: 2)

      get "/api/v1/workout_templates/#{template.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Push Day")
      expect(body["template_exercises"].length).to eq(2)
      expect(body["template_exercises"][0]["exercise_name"]).to eq("Bench Press")
      expect(body["template_exercises"][1]["exercise_name"]).to eq("Overhead Press")
    end

    it "returns 404 for another user's template" do
      template = create(:workout_template, user_id: other_user_id)

      get "/api/v1/workout_templates/#{template.id}", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for non-existent template" do
      get "/api/v1/workout_templates/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/workout_templates" do
    it "creates a template without exercises" do
      params = { workout_template: { name: "Push Day" } }

      post "/api/v1/workout_templates", params: params, headers: auth_headers
      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Push Day")
      expect(body["template_exercises"]).to eq([])
    end

    it "creates a template with nested exercises" do
      ex1 = create(:exercise, user_id: user_id, name: "Bench Press")
      ex2 = create(:exercise, user_id: user_id, name: "Overhead Press")

      params = {
        workout_template: {
          name: "Push Day",
          template_exercises_attributes: [
            { exercise_id: ex1.id, position: 1, default_sets: 4, default_reps: 8, default_weight: 135.0, rest_seconds: 90 },
            { exercise_id: ex2.id, position: 2, default_sets: 3, default_reps: 10, default_weight: 95.0, rest_seconds: 60 }
          ]
        }
      }

      post "/api/v1/workout_templates", params: params, headers: auth_headers
      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Push Day")
      expect(body["template_exercises"].length).to eq(2)
      expect(body["template_exercises"][0]["exercise_name"]).to eq("Bench Press")
      expect(body["template_exercises"][0]["default_sets"]).to eq(4)
      expect(body["template_exercises"][1]["exercise_name"]).to eq("Overhead Press")
      expect(body["template_exercises"][1]["position"]).to eq(2)
    end

    it "returns 422 for missing name" do
      params = { workout_template: { notes: "some notes" } }

      post "/api/v1/workout_templates", params: params, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Name can't be blank")
    end

    it "returns 422 for invalid nested exercise (missing position)" do
      exercise = create(:exercise, user_id: user_id)

      params = {
        workout_template: {
          name: "Push Day",
          template_exercises_attributes: [
            { exercise_id: exercise.id, default_sets: 3 }
          ]
        }
      }

      post "/api/v1/workout_templates", params: params, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/workout_templates/:id" do
    it "updates the template name" do
      template = create(:workout_template, user_id: user_id, name: "Push Day")

      params = { workout_template: { name: "Chest Day" } }
      patch "/api/v1/workout_templates/#{template.id}", params: params, headers: auth_headers
      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body["name"]).to eq("Chest Day")
    end

    it "adds a new exercise to existing template" do
      template = create(:workout_template, user_id: user_id, name: "Push Day")
      ex1 = create(:exercise, user_id: user_id, name: "Bench Press")
      create(:template_exercise, workout_template: template, exercise: ex1, position: 1)

      ex2 = create(:exercise, user_id: user_id, name: "Overhead Press")
      params = {
        workout_template: {
          template_exercises_attributes: [
            { exercise_id: ex2.id, position: 2, default_sets: 3, default_reps: 10 }
          ]
        }
      }

      patch "/api/v1/workout_templates/#{template.id}", params: params, headers: auth_headers
      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body["template_exercises"].length).to eq(2)
    end

    it "removes an exercise from template via _destroy" do
      template = create(:workout_template, user_id: user_id, name: "Push Day")
      ex1 = create(:exercise, user_id: user_id, name: "Bench Press")
      te = create(:template_exercise, workout_template: template, exercise: ex1, position: 1)

      params = {
        workout_template: {
          template_exercises_attributes: [
            { id: te.id, _destroy: true }
          ]
        }
      }

      patch "/api/v1/workout_templates/#{template.id}", params: params, headers: auth_headers
      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body["template_exercises"].length).to eq(0)
      expect(TemplateExercise.find_by(id: te.id)).to be_nil
    end

    it "reorders exercises" do
      template = create(:workout_template, user_id: user_id, name: "Push Day")
      ex1 = create(:exercise, user_id: user_id, name: "Bench Press")
      ex2 = create(:exercise, user_id: user_id, name: "Overhead Press")
      te1 = create(:template_exercise, workout_template: template, exercise: ex1, position: 1)
      te2 = create(:template_exercise, workout_template: template, exercise: ex2, position: 2)

      params = {
        workout_template: {
          template_exercises_attributes: [
            { id: te1.id, position: 2 },
            { id: te2.id, position: 1 }
          ]
        }
      }

      patch "/api/v1/workout_templates/#{template.id}", params: params, headers: auth_headers
      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      exercises = body["template_exercises"].sort_by { |te| te["position"] }
      expect(exercises[0]["exercise_name"]).to eq("Overhead Press")
      expect(exercises[1]["exercise_name"]).to eq("Bench Press")
    end

    it "returns 404 for another user's template" do
      template = create(:workout_template, user_id: other_user_id)
      params = { workout_template: { name: "Hacked" } }

      patch "/api/v1/workout_templates/#{template.id}", params: params, headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns 422 for invalid update" do
      template = create(:workout_template, user_id: user_id, name: "Push Day")
      params = { workout_template: { name: "" } }

      patch "/api/v1/workout_templates/#{template.id}", params: params, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/workout_templates/:id" do
    it "deletes the template and its template_exercises" do
      template = create(:workout_template, user_id: user_id, name: "Push Day")
      exercise = create(:exercise, user_id: user_id)
      te = create(:template_exercise, workout_template: template, exercise: exercise, position: 1)

      delete "/api/v1/workout_templates/#{template.id}", headers: auth_headers
      expect(response).to have_http_status(:no_content)

      expect(WorkoutTemplate.find_by(id: template.id)).to be_nil
      expect(TemplateExercise.find_by(id: te.id)).to be_nil
    end

    it "returns 404 for another user's template" do
      template = create(:workout_template, user_id: other_user_id)

      delete "/api/v1/workout_templates/#{template.id}", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
