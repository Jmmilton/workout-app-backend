require "net/http"

class JwtDecoder
  class DecodeError < StandardError; end

  def self.decode(token)
    header = JWT.decode(token, nil, false).last

    case header["alg"]
    when "ES256"
      payload, = JWT.decode(token, nil, true, algorithms: [ "ES256" ], jwks: cached_jwks)
      payload
    when "HS256", "HS384", "HS512"
      secret = ENV.fetch("SUPABASE_JWT_SECRET")
      payload, = JWT.decode(token, secret, true, algorithms: [ header["alg"] ])
      payload
    else
      raise DecodeError, "Unsupported algorithm: #{header["alg"]}"
    end
  rescue JWT::ExpiredSignature
    raise DecodeError, "Token has expired"
  rescue JWT::DecodeError => e
    raise DecodeError, "Invalid token: #{e.message}"
  rescue KeyError => e
    raise DecodeError, "Missing configuration: #{e.message}"
  end

  def self.cached_jwks
    if @jwks_data && @jwks_fetched_at && (Time.now - @jwks_fetched_at) < 3600
      return @jwks_data
    end

    supabase_url = ENV.fetch("SUPABASE_URL")
    uri = URI("#{supabase_url}/auth/v1/.well-known/jwks.json")
    response = Net::HTTP.get(uri)
    @jwks_data = JSON.parse(response)
    @jwks_fetched_at = Time.now
    @jwks_data
  end

  def self.clear_cache!
    @jwks_data = nil
    @jwks_fetched_at = nil
  end
end
