module Api
  module V1
    class ImportsController < ApplicationController
      def csv
        unless params[:file].present?
          return render json: { error: "No file provided" }, status: :bad_request
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
