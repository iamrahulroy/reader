source "https://rubygems.org"
gem "nokogiri", "~> 1.5"
gem "rails", "~> 3.2"
gem "unicorn", "~> 4.4"
gem "god", "~> 0.13"

gem "sidekiq", "~> 2.6"
gem "sidekiq-failures", "~> 0.1"
gem "sidekiq-limit_fetch", "~> 1.1"
gem "sinatra", "~> 1.3", :require => false
gem "slim", "~> 1.3", :require => false
gem "thin", "~> 1.5", :require => false

gem 'resque'
gem 'sucker_punch'

gem "pg", "~> 0.14"
gem "devise", "~> 2.2"
gem "acts_as_follower", "~> 0.1"
gem "fb_graph", "~> 2.6"
gem "feeder", git: "https://github.com/1kplus/feeder.git"
#gem "feeder", path: "/Users/charlie/Workspace/feeder"

gem "feedzirra", git: "https://github.com/1kplus/feedzirra.git"
gem "muck-feedbag", git: "https://github.com/1kplus/feedbag.git"

gem "hpricot", "~> 0.8"
gem "private_pub", "~> 1.0"
gem "libxml-ruby", "~> 2.3"
gem "curb", "~> 0.8"
gem "typhoeus", "~> 0.5"
gem "faraday", "~> 0.8"
gem "faraday_middleware", "~> 0.9"
gem "embedly", "~> 1.5"
gem "haml", "~> 4.0"
gem "active_model_serializers", "~> 0.6"
gem "oj", "~> 2.0"
gem "loofah", "~> 1.2"
gem "ensure-encoding", "~> 0.1"
gem "pismo", "~> 0.7"
gem "carrierwave", "~> 0.8"
gem "capistrano", "~> 2.0"
gem "rvm-capistrano", "~> 1.2"
gem "figaro", "~> 0.6"

gem "pry-rails", "~> 0.2"
gem "pry-debugger"
gem "pry-coolline"
gem "pry-remote"



group :production do
  gem "newrelic_rpm", "~> 3.5"
end

group :development do
  gem "better_errors", "~> 0.6"
  gem "binding_of_caller", "~> 0.7"
  gem "meta_request", "~> 0.2"
  gem "erb2haml", "~> 0.1"
  gem "mails_viewer", "~> 0.0"
  gem "foreman", "~> 0.61"
end

group :test, :development do
  gem "ruby_gntp"
  gem "awesome_print", "~> 1.1"

  gem "sextant", "~> 0.2"
  gem "rspec-rails", "~> 2.12"
  gem "quiet_assets", "~> 1.0"
  gem "jasmine-rails", "~> 0.3"
end

group :test do
  gem "database_cleaner", "~> 0.9"
  gem "capybara", "~> 1.0"
  gem "vcr", "~> 2.4"
  gem "webmock", "1.9"
  gem "launchy", "~> 2.2"
end

group :assets do
  gem "jquery-rails", "~> 2.2"
  gem "sass-rails", "~> 3.2"
  gem "bootstrap-sass", "~> 2.3"
  gem "coffee-rails", "~> 3.2"
  gem "compass-rails", "~> 1.0"
  gem "handlebars_assets", " ~> 0.10"
  gem "uglifier", "~> 1.3"
  gem "turbo-sprockets-rails3", "~> 0.3"
end
