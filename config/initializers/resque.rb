rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
rails_env = Rails.env || 'development'

resque_config = YAML.load_file(rails_root.to_s + '/config/redis.yml')
Resque.redis = resque_config[rails_env]
Resque.redis.namespace = "resque:reader"

Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }