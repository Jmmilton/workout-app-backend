class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    if token.blank?
      render json: { error: "Authorization header is required" }, status: :unauthorized
      return
    end

    payload = JwtDecoder.decode(token)
    @current_user_id = payload["sub"]
  rescue JwtDecoder::DecodeError => e
    render json: { error: e.message }, status: :unauthorized
  end

  def current_user_id
    @current_user_id
  end
end
