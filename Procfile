web:         bundle exec unicorn -p $PORT -c ./config/unicorn.rb
private_pub: rackup -s thin -E production private_pub.ru
worker:      bundle exec sidekiq -C ./config/sidekiq.yml

