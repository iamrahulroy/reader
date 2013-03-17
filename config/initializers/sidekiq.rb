rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
redis_config = YAML.load_file(rails_root.to_s + '/config/redis.yml')
rails_env = Rails.env || 'development'

puts "redis url: #{redis_config[rails_env]}"


Sidekiq.configure_server do |config|
  config.redis = { :url => redis_config[rails_env], :namespace => 'sidekiq:reader' }
  if ENV["DATABASE_URL"]
    ActiveRecord::Base.establish_connection "#{ENV["DATABASE_URL"]}?pool=150"
  end
end