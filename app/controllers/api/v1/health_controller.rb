module Api
  module V1
    class HealthController < ApplicationController
      def show
        render json: { status: "ok", user_id: current_user_id }
      end
    end
  end
end
