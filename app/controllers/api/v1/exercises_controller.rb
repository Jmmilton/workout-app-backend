module Api
  module V1
    class ExercisesController < ApplicationController
      before_action :set_exercise, only: [:show, :update, :destroy]

      def index
        exercises = Exercise.where(user_id: current_user_id)
        exercises = exercises.where(muscle_group: params[:muscle_group]) if params[:muscle_group].present?
        exercises = exercises.where(equipment_type: params[:equipment_type]) if params[:equipment_type].present?
        exercises = exercises.order(:name)

        render json: exercises, each_serializer: ExerciseSerializer
      end

      def show
        render json: @exercise, serializer: ExerciseSerializer
      end

      def create
        exercise = Exercise.new(exercise_params.merge(user_id: current_user_id))

        if exercise.save
          render json: exercise, serializer: ExerciseSerializer, status: :created
        else
          render json: { errors: exercise.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @exercise.update(exercise_params)
          render json: @exercise, serializer: ExerciseSerializer
        else
          render json: { errors: @exercise.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @exercise.destroy
          head :no_content
        else
          render json: { errors: @exercise.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_exercise
        @exercise = Exercise.find_by!(id: params[:id], user_id: current_user_id)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Exercise not found" }, status: :not_found
      end

      def exercise_params
        params.require(:exercise).permit(:name, :muscle_group, :equipment_type, :notes)
      end
    end
  end
end
