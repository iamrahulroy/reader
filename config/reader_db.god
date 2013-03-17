God.pid_file_directory = "/tmp/"

rails_env   = ENV['RAILS_ENV'] || "development"
rails_root  = ENV['RAILS_ROOT'] || File.expand_path('../../', __FILE__).to_s

God.watch do |w|
  w.group = "reader"
  w.name = "resque"
  w.env = { 'COUNT' => "3",
            'INTERVAL' => "1",
            'QUEUE' => "*",
            'RAILS_ENV' => rails_env}

  w.dir = "#{rails_root}"
  w.start = "bundle exec rake resque:workers"
  w.stop_signal = 'QUIT'
  w.stop_timeout = 120.seconds
  w.log = "#{rails_root}/log/resque.log"
  w.keepalive
end






