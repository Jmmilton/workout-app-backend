module Api
  module V1
    class WorkoutExercisesController < ApplicationController
      before_action :set_workout
      before_action :set_workout_exercise, only: [:update, :destroy]

      def create
        position = @workout.workout_exercises.maximum(:position).to_i + 1

        we = @workout.workout_exercises.build(
          exercise_id: exercise_params[:exercise_id],
          position: position,
          rest_seconds: exercise_params[:rest_seconds] || 90,
          notes: exercise_params[:notes]
        )

        sets_count = (exercise_params[:sets_count] || 3).to_i
        sets_count.times do |i|
          we.workout_sets.build(set_order: i + 1, completed: false)
        end

        if we.save
          we.reload
          render json: we, serializer: WorkoutExerciseSerializer, status: :created
        else
          render json: { errors: we.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @workout_exercise.update(exercise_update_params)
          render json: @workout_exercise, serializer: WorkoutExerciseSerializer
        else
          render json: { errors: @workout_exercise.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @workout_exercise.destroy!
        head :no_content
      end

      private

      def set_workout
        @workout = Workout.find_by!(id: params[:workout_id], user_id: current_user_id)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Workout not found" }, status: :not_found
      end

      def set_workout_exercise
        @workout_exercise = @workout.workout_exercises.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Workout exercise not found" }, status: :not_found
      end

      def exercise_params
        params.require(:workout_exercise).permit(:exercise_id, :rest_seconds, :notes, :sets_count)
      end

      def exercise_update_params
        params.require(:workout_exercise).permit(:position, :rest_seconds, :notes)
      end
    end
  end
end
