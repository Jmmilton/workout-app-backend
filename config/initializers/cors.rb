Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(ENV.fetch("RACK_CORS_ORIGINS", "http://localhost:5173").split(","))

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["Authorization"]
  end
end
