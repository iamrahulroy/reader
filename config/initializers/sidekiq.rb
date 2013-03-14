Sidekiq.configure_server do |config|

  if Rails.env.production?
    database_url = "postgres://#{ENV['PG_USER']}:#{ENV['PG_PASS']}@#{ENV['PG_HOST']}/reader_production"
  elsif Rails.env.development?
    database_url = "postgres://reader@localhost/reader_development"
  end

  if (database_url)
    ENV['DATABASE_URL'] = "#{database_url}?pool=81"
    ActiveRecord::Base.establish_connection
  end
end
