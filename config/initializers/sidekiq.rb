Sidekiq.configure_server do |config|

  if Rails.env.production?
    database_url = ENV['READER_DATABASE_URL']
  elsif Rails.env.development?
    database_url = "postgres://reader@localhost/reader_development?pool=81"
  end

  if (database_url)
    ENV['DATABASE_URL'] = "#{database_url}"
    ActiveRecord::Base.establish_connection
  end
end
