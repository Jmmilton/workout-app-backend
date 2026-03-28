Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"
      resources :exercises
      resources :workout_templates

      post "imports/csv", to: "imports#csv"

      resources :workouts do
        get :calendar, on: :collection
        resources :exercises, controller: "workout_exercises", only: [:create, :update, :destroy] do
          resources :sets, controller: "workout_sets", only: [:create, :update, :destroy]
        end
      end
    end
  end
end
