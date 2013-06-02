Factory.define do
  factory :user do
    email "james@example.org"
    name "James"
    password "123456789"
    password_confirmation "123456789"
  end
end
