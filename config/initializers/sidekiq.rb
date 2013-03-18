rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
redis_config = YAML.load_file(rails_root.to_s + '/config/redis.yml')
rails_env = Rails.env || 'production'

Sidekiq.configure_server do |config|
  config.redis = { :url => redis_config[rails_env], :namespace => 'reader' }
  if ENV["DATABASE_URL"]
    ActiveRecord::Base.establish_connection "#{ENV["DATABASE_URL"]}?pool=105"
  end
end

Sidekiq.configure_client do |config|
  config.redis = { :url => redis_config[rails_env], :namespace => 'reader' }
end