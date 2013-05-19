class NewUserSetup
  include Sidekiq::Worker
  sidekiq_options :queue => :users
  def perform(id)
    user = User.find id

    user.subscriptions.each do |sub|
      entries = sub.source.entries.where("created_at > ?", 2.weeks.ago)
      if entries.count < 25
        entries = sub.source.entries.limit(25)
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