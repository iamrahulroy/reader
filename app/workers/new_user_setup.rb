class NewUserSetup
  include Sidekiq::Worker
  sidekiq_options :queue => :users
  def perform(id)
    user = User.find id

    user.subscriptions.each do |sub|
      entries = sub.feed.entries.where("created_at > ?", Date.current - 2.weeks)
      if entries.count < 25
        entries = sub.feed.entries.limit(25)
      end
      entries.each do |entry|
        item = Item.new(:user_id => sub.user_id, :entry => entry, :subscription => sub)
        if item.valid?
          item.save
        end
      end

      sub.update_counts
    end
  end

end