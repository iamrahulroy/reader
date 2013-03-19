# config/unicorn.rb
ENV["RAILS_ENV"] ||= "development"
worker_processes Integer(ENV["UNICORN_WORKERS"] || 20)
timeout Integer(ENV["UNICORN_TIMEOUT"] || 60)
preload_app true
listen "/tmp/unicorn.reader.sock", :backlog => 364
pid "/tmp/unicorn.reader.pid"

# Production specific settings
if ENV["RAILS_ENV"] == "production"
  # Help ensure your application will always spawn in the symlinked
  # "current" directory that Capistrano sets up.
  working_directory "/home/charlie/apps/reader/current"

  # feel free to point this anywhere accessible on the filesystem
  user 'charlie', 'staff'
  shared_path = "/home/charlie/apps/reader/shared"

  stderr_path "#{shared_path}/log/unicorn.stderr.log"
  stdout_path "#{shared_path}/log/unicorn.stdout.log"
end

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection

  if defined?(Sidekiq)
    Sidekiq.configure_client do |config|
      rails_root = Rails.root || File.join(File.dirname(__FILE__), "..", "..")
      redis_config = YAML.load_file(File.join(rails_root, "config", "redis.yml"))
      config.redis = { url: redis_config[ENV["RAILS_ENV"]], namespace: 'reader', size: 1 }
    end
  end
end
