web:         bundle exec rails s
private_pub: rackup -s thin -E production private_pub.ru
worker:      bundle exec sidekiq -C ./config/sidekiq.yml
resque:      rake resque:workers
