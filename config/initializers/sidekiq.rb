Sidekiq.configure_server do |config|
  if ENV["DATABASE_URL"]
    ActiveRecord::Base.establish_connection
  end
end
