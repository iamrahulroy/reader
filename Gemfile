if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'https://rubygems.org'


gem "nokogiri"
gem 'rails', '~> 3.2'
gem 'unicorn', '~> 4.4'
#gem 'puma'
gem 'god', '~> 0.13'

gem 'sidekiq', '~> 2.6'
gem 'sidekiq-failures'
gem 'sidekiq-limit_fetch'
# required for sidekiq web
gem 'sinatra', '~> 1.3', :require => false
gem 'slim', '~> 1.3', :require => false
gem 'thin', '~> 1.5', :require => false

gem 'pg'

gem 'devise'
gem 'acts_as_follower'
gem 'fb_graph' # TODO: don't need this

gem 'feeder', :path => 'feeder'
gem 'feedzirra', :path => 'vendor/feedzirra'
gem 'muck-feedbag', :path => 'vendor/feedbag'
gem 'hpricot', '~> 0.8'
gem 'private_pub'
gem 'libxml-ruby', '~> 2.3'
gem 'curb', '~> 0.8'
gem 'typhoeus', '~> 0.5'
gem 'faraday'
gem 'faraday_middleware'

gem 'embedly'

gem 'haml'
gem "active_model_serializers"
gem 'oj'


gem 'loofah'
gem 'ensure-encoding'
gem 'pismo'
gem 'carrierwave'

gem 'pry-rails'
gem 'pry-nav'
gem 'awesome_print'

gem 'newrelic_rpm'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'erb2haml'
  gem 'mails_viewer'
  gem 'capistrano'
  gem 'rvm-capistrano'
  gem 'foreman'
end

group :test, :development do
  gem "sextant"
  gem 'rspec-rails'
  gem 'quiet_assets'
  gem 'jasmine-rails'
end

group :test do
  gem 'database_cleaner'
  gem 'capybara', '~> 1.0'
  gem 'vcr'
  gem 'webmock'
  gem 'launchy'
end

group :assets do
  gem 'jquery-rails'
  gem 'sass-rails'
  gem 'bootstrap-sass'
  gem 'coffee-rails'
  gem 'compass-rails'
  gem 'handlebars_assets', '0.10.0'
  gem 'uglifier'
  gem 'turbo-sprockets-rails3'
end
