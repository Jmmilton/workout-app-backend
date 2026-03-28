class ApplicationController < ActionController::API
  before_action :authenticate_user!
  before_action :seed_defaults_for_new_user

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

  def seed_defaults_for_new_user
    return if Rails.env.test?
    return unless @current_user_id
    return if Exercise.exists?(user_id: @current_user_id)

    DefaultExerciseSeeder.new(@current_user_id).call
    DefaultTemplateSeeder.new(@current_user_id).call
  end
end
