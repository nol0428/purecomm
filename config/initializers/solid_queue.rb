# config/initializers/solid_queue.rb
SolidQueue.configure do |config|
  # Force Solid Queue to use the primary DB in production
  config.database = :primary
end
