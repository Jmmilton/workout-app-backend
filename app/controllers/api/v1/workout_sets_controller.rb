module Api
  module V1
    class WorkoutSetsController < ApplicationController
      before_action :set_workout
      before_action :set_workout_exercise
      before_action :set_workout_set, only: [ :update, :destroy ]

      def create
        set_order = @workout_exercise.workout_sets.maximum(:set_order).to_i + 1
        previous_set = @workout_exercise.workout_sets.order(set_order: :desc).first

        create_params = if params.key?(:workout_set)
          set_params
        else
          {}
        end

        workout_set = @workout_exercise.workout_sets.build(
          set_order: set_order,
          weight: create_params[:weight] || previous_set&.weight,
          reps: create_params[:reps] || previous_set&.reps,
          completed: false
        )

        if workout_set.save
          render json: workout_set, serializer: WorkoutSetSerializer, status: :created
        else
          render json: { errors: workout_set.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        completed_param = set_update_params[:completed]
        completing = ActiveModel::Type::Boolean.new.cast(completed_param)

        if completing == true && !@workout_set.completed
          @workout_set.complete!
          @workout_set.reload
          render json: @workout_set, serializer: WorkoutSetSerializer
        elsif completing == false && @workout_set.completed
          @workout_set.uncomplete!
          remaining = set_update_params.except(:completed)
          if remaining.empty? || @workout_set.update(remaining)
            @workout_set.reload
            render json: @workout_set, serializer: WorkoutSetSerializer
          else
            render json: { errors: @workout_set.errors.full_messages }, status: :unprocessable_entity
          end
        elsif @workout_set.update(set_update_params.except(:completed))
          render json: @workout_set, serializer: WorkoutSetSerializer
        else
          render json: { errors: @workout_set.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @workout_set.destroy!
        head :no_content
      end

      private

      def set_workout
        @workout = Workout.find_by!(id: params[:workout_id], user_id: current_user_id)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Workout not found" }, status: :not_found
      end

      def set_workout_exercise
        @workout_exercise = @workout.workout_exercises.find(params[:exercise_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Workout exercise not found" }, status: :not_found
      end

      def set_workout_set
        @workout_set = @workout_exercise.workout_sets.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Workout set not found" }, status: :not_found
      end

      def set_params
        params.require(:workout_set).permit(:weight, :reps, :rpe, :notes)
      end

      def set_update_params
        params.require(:workout_set).permit(:weight, :reps, :rpe, :notes, :completed)
      end
    end
  end
end
