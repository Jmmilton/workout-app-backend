module Api
  module V1
    class ImportsController < ApplicationController
      MAX_FILE_SIZE = 5.megabytes
      MAX_ROWS = 50_000

      def csv
        unless params[:file].present?
          return render json: { error: "No file provided" }, status: :bad_request
        end

        if params[:file].size > MAX_FILE_SIZE
          return render json: { error: "File too large (max 5MB)" }, status: :unprocessable_content
        end

        csv_content = params[:file].read
        importer = CsvImporter.new(csv_content, @current_user_id)
        result = importer.call

        render json: {
          exercises_created: result.exercises_created,
          workouts_created: result.workouts_created,
          sets_created: result.sets_created
        }, status: :created
      rescue CSV::MalformedCSVError => e
        render json: { error: "Invalid CSV file: #{e.message}" }, status: :unprocessable_content
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_content
      end
    end
  end
end
