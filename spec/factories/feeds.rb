FactoryGirl.define do
  factory :feed do
    name "Example"
    site_url "http://example.com"
    feed_url "http://example.com/feed.rss"
    description "Yada Yada"
    suggested false
    user
  end
end
