God.pid_file_directory = "/tmp/"

rails_env   = "production"
rails_root  = ENV['RAILS_ROOT'] || File.expand_path('../../', __FILE__).to_s

God.watch do |w|
  w.group = "reader"
  w.name = "sidekiq"
  w.dir = "#{rails_root}"
  w.env = { 'RAILS_ENV' => rails_env }
  w.start = "bundle exec sidekiq -e #{rails_env} -C #{rails_root}/config/sidekiq_db.yml"
  w.log = "#{rails_root}/log/sidekiq.log"
  w.keepalive
  w.interval = 10.seconds

  w.restart_if do |restart|
    restart.condition(:cpu_usage) do |c|
      c.above = 90.percent
      c.times = 15
    end
  end
end

God.watch do |w|
  w.group = "reader"
  w.name = "resque"
  w.env = { 'COUNT' => "2",
            'INTERVAL' => "1",
            'QUEUE' => "opml",
            'RAILS_ENV' => rails_env}

  w.dir = "#{rails_root}"
  w.start = "bundle exec rake resque:workers"
  w.stop_signal = 'QUIT'
  w.stop_timeout = 120.seconds
  w.log = "#{rails_root}/log/resque.log"
  w.keepalive
  w.interval = 10.seconds

  w.restart_if do |restart|
    restart.condition(:cpu_usage) do |c|
      c.above = 90.percent
      c.times = 15
    end
  end
end






