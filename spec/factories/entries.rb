FactoryGirl.define do
  factory :entry do
    title "Title"
    url "http://example.org/"
    author "James"
    summary "Yada Yada"
    content "Yada Yada Yada Yada"
    user
    feed
  end
end
