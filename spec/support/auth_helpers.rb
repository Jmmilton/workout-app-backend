module AuthHelpers
  TEST_USER_ID = "550e8400-e29b-41d4-a716-446655440000"

  def auth_headers(user_id: TEST_USER_ID)
    payload = { "sub" => user_id, "exp" => 1.hour.from_now.to_i }
    secret = ENV.fetch("SUPABASE_JWT_SECRET")
    token = JWT.encode(payload, secret, "HS256")
    { "Authorization" => "Bearer #{token}" }
  end

  def expired_auth_headers
    payload = { "sub" => TEST_USER_ID, "exp" => 1.hour.ago.to_i }
    secret = ENV.fetch("SUPABASE_JWT_SECRET")
    token = JWT.encode(payload, secret, "HS256")
    { "Authorization" => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
