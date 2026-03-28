module Api
  module V1
    class WorkoutTemplatesController < ApplicationController
      before_action :set_template, only: [ :show, :update, :destroy ]

      def index
        templates = WorkoutTemplate
          .where(user_id: current_user_id)
          .includes(template_exercises: :exercise)
          .order(:name)

        render json: templates, each_serializer: WorkoutTemplateSerializer
      end

      def show
        render json: @template, serializer: WorkoutTemplateSerializer
      end

      def create
        template = WorkoutTemplate.new(template_params.merge(user_id: current_user_id))

        if template.save
          template.reload
          render json: template, serializer: WorkoutTemplateSerializer, status: :created
        else
          render json: { errors: template.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @template.update(template_params)
          @template.reload
          render json: @template, serializer: WorkoutTemplateSerializer
        else
          render json: { errors: @template.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @template.destroy!
        head :no_content
      end

      private

      def set_template
        @template = WorkoutTemplate.find_by!(id: params[:id], user_id: current_user_id)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Workout template not found" }, status: :not_found
      end

      def template_params
        params.require(:workout_template).permit(
          :name,
          :notes,
          template_exercises_attributes: [
            :id, :exercise_id, :position, :default_sets, :default_reps,
            :default_weight, :rest_seconds, :notes, :_destroy
          ]
        )
      end
    end
  end
end
