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
end







