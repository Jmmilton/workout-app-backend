require "rails_helper"

RSpec.describe "Api::V1::Imports", type: :request do
  let(:user_id) { AuthHelpers::TEST_USER_ID }
  let(:csv_path) { Rails.root.join("spec/fixtures/sample_import.csv") }

  describe "POST /api/v1/imports/csv" do
    it "imports the CSV and returns summary" do
      file = Rack::Test::UploadedFile.new(csv_path, "text/csv")
      post "/api/v1/imports/csv", params: { file: file }, headers: auth_headers

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)
      expect(body["exercises_created"]).to eq(6)
      expect(body["workouts_created"]).to eq(3)
      expect(body["sets_created"]).to eq(13)
    end

    it "returns 400 when no file is provided" do
      post "/api/v1/imports/csv", headers: auth_headers

      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("No file provided")
    end

    it "returns 422 for malformed CSV" do
      bad_file = Rack::Test::UploadedFile.new(
        StringIO.new("not,a,valid\ncsv\"broken"),
        "text/csv",
        true,
        original_filename: "bad.csv"
      )
      post "/api/v1/imports/csv", params: { file: bad_file }, headers: auth_headers

      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["error"]).to match(/Invalid CSV|Validation failed/i)
    end

    it "requires authentication" do
      file = Rack::Test::UploadedFile.new(csv_path, "text/csv")
      post "/api/v1/imports/csv", params: { file: file }

      expect(response).to have_http_status(:unauthorized)
    end

    it "scopes imported data to the authenticated user" do
      file = Rack::Test::UploadedFile.new(csv_path, "text/csv")
      post "/api/v1/imports/csv", params: { file: file }, headers: auth_headers

      expect(Exercise.where(user_id: user_id).count).to eq(6)
      expect(Workout.where(user_id: user_id).count).to eq(3)
    end

    it "returns 422 on duplicate import (exercise uniqueness violation)" do
      file1 = Rack::Test::UploadedFile.new(csv_path, "text/csv")
      post "/api/v1/imports/csv", params: { file: file1 }, headers: auth_headers
      expect(response).to have_http_status(:created)

      file2 = Rack::Test::UploadedFile.new(csv_path, "text/csv")
      post "/api/v1/imports/csv", params: { file: file2 }, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_content)

      body = JSON.parse(response.body)
      expect(body["error"]).to match(/already been taken/i)
    end
  end
end
