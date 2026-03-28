require "rails_helper"

RSpec.describe JwtDecoder do
  let(:user_id) { "550e8400-e29b-41d4-a716-446655440000" }

  after { described_class.clear_cache! }

  describe ".decode with HS256" do
    let(:secret) { ENV.fetch("SUPABASE_JWT_SECRET") }

    it "decodes a valid token" do
      payload = { "sub" => user_id, "exp" => 1.hour.from_now.to_i }
      token = JWT.encode(payload, secret, "HS256")

      result = described_class.decode(token)
      expect(result["sub"]).to eq(user_id)
    end

    it "raises DecodeError for an expired token" do
      payload = { "sub" => user_id, "exp" => 1.hour.ago.to_i }
      token = JWT.encode(payload, secret, "HS256")

      expect { described_class.decode(token) }.to raise_error(
        JwtDecoder::DecodeError, "Token has expired"
      )
    end

    it "raises DecodeError for an invalid token" do
      expect { described_class.decode("invalid.token.here") }.to raise_error(
        JwtDecoder::DecodeError, /Invalid token/
      )
    end

    it "raises DecodeError for a token signed with wrong secret" do
      payload = { "sub" => user_id, "exp" => 1.hour.from_now.to_i }
      token = JWT.encode(payload, "wrong-secret-that-is-long-enough", "HS256")

      expect { described_class.decode(token) }.to raise_error(
        JwtDecoder::DecodeError, /Invalid token/
      )
    end
  end

  describe ".decode with ES256" do
    let(:ec_key) { OpenSSL::PKey::EC.generate("prime256v1") }
    let(:jwk) { JWT::JWK.new(ec_key, kid: "test-key-id") }
    let(:jwks_hash) { { keys: [jwk.export] } }

    before do
      allow(described_class).to receive(:cached_jwks).and_return(jwks_hash)
    end

    it "decodes a valid ES256 token" do
      payload = { "sub" => user_id, "exp" => 1.hour.from_now.to_i }
      token = JWT.encode(payload, ec_key, "ES256", { kid: "test-key-id" })

      result = described_class.decode(token)
      expect(result["sub"]).to eq(user_id)
    end

    it "raises DecodeError for an expired ES256 token" do
      payload = { "sub" => user_id, "exp" => 1.hour.ago.to_i }
      token = JWT.encode(payload, ec_key, "ES256", { kid: "test-key-id" })

      expect { described_class.decode(token) }.to raise_error(
        JwtDecoder::DecodeError, "Token has expired"
      )
    end

    it "raises DecodeError for a token signed with wrong key" do
      other_key = OpenSSL::PKey::EC.generate("prime256v1")
      payload = { "sub" => user_id, "exp" => 1.hour.from_now.to_i }
      token = JWT.encode(payload, other_key, "ES256", { kid: "test-key-id" })

      expect { described_class.decode(token) }.to raise_error(
        JwtDecoder::DecodeError, /Invalid token/
      )
    end
  end

  describe ".decode with unsupported algorithm" do
    it "raises DecodeError" do
      # Create a token with PS256 header manually
      header = Base64.urlsafe_encode64({ alg: "PS256", typ: "JWT" }.to_json, padding: false)
      payload = Base64.urlsafe_encode64({ sub: user_id }.to_json, padding: false)
      fake_token = "#{header}.#{payload}.fakesig"

      expect { described_class.decode(fake_token) }.to raise_error(
        JwtDecoder::DecodeError, /Unsupported algorithm/
      )
    end
  end
end
