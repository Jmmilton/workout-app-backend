require "rails_helper"

RSpec.describe "Api::V1::Health", type: :request do
  describe "GET /api/v1/health" do
    context "without authentication" do
      it "returns 401 unauthorized" do
        get "/api/v1/health"
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Authorization header is required")
      end
    end

    context "with expired token" do
      it "returns 401 unauthorized" do
        get "/api/v1/health", headers: expired_auth_headers
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Token has expired")
      end
    end

    context "with invalid token" do
      it "returns 401 unauthorized" do
        get "/api/v1/health", headers: { "Authorization" => "Bearer invalid.token" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with valid authentication" do
      it "returns 200 with status and user_id" do
        get "/api/v1/health", headers: auth_headers
        expect(response).to have_http_status(:ok)

        body = JSON.parse(response.body)
        expect(body["status"]).to eq("ok")
        expect(body["user_id"]).to eq(AuthHelpers::TEST_USER_ID)
      end
    end
  end
end
