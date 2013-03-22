web:         puma --config config/puma.rb
private_pub: rackup -s thin -E production private_pub.ru
sidekiq:     bundle exec sidekiq -C ./config/sidekiq_dev.yml
