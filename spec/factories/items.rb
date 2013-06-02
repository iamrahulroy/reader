FactoryGirl.define do
  factory :item do
    unread true
    starred false
    shared true
    browsed false
    user
    entry
  end
end
