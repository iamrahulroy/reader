Sidekiq.configure_server do |config|
  if ENV["DATABASE_URL"]
    ActiveRecord::Base.establish_connection "#{ENV["DATABASE_URL"]}?pool=150"
  end
end