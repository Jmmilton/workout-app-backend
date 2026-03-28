module Api
  module V1
    class WorkoutsController < ApplicationController
      before_action :set_workout, only: [ :show, :update, :destroy ]

      def index
        workouts = Workout
          .where(user_id: current_user_id)
          .select(
            "workouts.*",
            "(SELECT COUNT(*) FROM workout_exercises WHERE workout_exercises.workout_id = workouts.id) AS cached_exercise_count",
            "(SELECT COUNT(*) FROM workout_sets INNER JOIN workout_exercises ON workout_sets.workout_exercise_id = workout_exercises.id WHERE workout_exercises.workout_id = workouts.id) AS cached_set_count"
          )
          .order(started_at: :desc)

        workouts = workouts.where(status: params[:status]) if params[:status].present?

        if params[:start_date].present? && params[:end_date].present?
          workouts = workouts.by_date(Date.parse(params[:start_date]), Date.parse(params[:end_date]))
        end

        workouts = workouts.page(params[:page]).per(params[:per_page] || 20)

        render json: workouts, each_serializer: WorkoutSummarySerializer
      end

      def calendar
        year = (params[:year] || Date.current.year).to_i
        month = (params[:month] || Date.current.month).to_i
        start_date = Date.new(year, month, 1)
        end_date = start_date.end_of_month

        workouts = Workout
          .where(user_id: current_user_id, status: "completed")
          .by_date(start_date, end_date)
          .select(:id, :name, :started_at)
          .order(:started_at)

        entries = workouts.map do |w|
          { date: w.started_at.to_date.iso8601, workout_name: w.name, workout_id: w.id }
        end

        render json: entries
      end

      def show
        render json: @workout, serializer: WorkoutSerializer
      end

      def create
        workout = build_workout

        if workout.save
          workout = Workout
            .includes(workout_exercises: [ :exercise, :workout_sets ])
            .find(workout.id)
          render json: workout, serializer: WorkoutSerializer, status: :created
        else
          render json: { errors: workout.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if params[:status] == "completed"
          @workout.complete!
          @workout.reload
          render json: @workout, serializer: WorkoutSerializer
        elsif params[:status] == "cancelled"
          @workout.cancel!
          @workout.reload
          render json: @workout, serializer: WorkoutSerializer
        elsif @workout.update(workout_update_params)
          @workout.reload
          render json: @workout, serializer: WorkoutSerializer
        else
          render json: { errors: @workout.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @workout.destroy!
        head :no_content
      end

      private

      def set_workout
        @workout = Workout
          .includes(workout_exercises: [ :exercise, :workout_sets ])
          .find_by!(id: params[:id], user_id: current_user_id)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Workout not found" }, status: :not_found
      end

      def build_workout
        if params[:template_id].present?
          build_from_template
        else
          Workout.new(workout_create_params.merge(
            user_id: current_user_id,
            started_at: Time.current,
            status: "active"
          ))
        end
      end

      def build_from_template
        template = WorkoutTemplate
          .includes(template_exercises: :exercise)
          .find_by!(id: params[:template_id], user_id: current_user_id)

        workout = Workout.new(
          user_id: current_user_id,
          workout_template_id: template.id,
          name: params.dig(:workout, :name) || template.name,
          started_at: Time.current,
          status: "active",
          notes: params.dig(:workout, :notes)
        )

        template.template_exercises.each do |te|
          we = workout.workout_exercises.build(
            exercise_id: te.exercise_id,
            position: te.position,
            rest_seconds: te.rest_seconds,
            notes: te.notes
          )

          sets_count = te.default_sets || 3
          sets_count.times do |i|
            we.workout_sets.build(
              set_order: i + 1,
              weight: te.default_weight,
              reps: te.default_reps,
              completed: false
            )
          end
        end

        workout
      rescue ActiveRecord::RecordNotFound
        workout = Workout.new
        workout.errors.add(:base, "Template not found")
        workout
      end

      def workout_create_params
        params.require(:workout).permit(:name, :notes)
      end

      def workout_update_params
        params.require(:workout).permit(:name, :notes)
      end
    end
  end
end
