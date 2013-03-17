require 'resque/tasks'

task "resque:setup" => :environment do
  Resque.after_fork do
    Resque.redis.client.reconnect
  end
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end