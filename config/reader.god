God.pid_file_directory = "/tmp/"
God.watch do |w|
  w.group = "reader"
  w.name = "sidekiq"
  w.dir = "#{File.expand_path('../../', __FILE__)}"
  w.start = "bundle exec sidekiq -e production -C #{File.expand_path('../../', __FILE__)}/config/sidekiq.yml"
  w.log = "#{File.expand_path('../../', __FILE__)}/log/sidekiq.log"
  w.keepalive
end
