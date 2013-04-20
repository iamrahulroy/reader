module Reader
  class Setup
    def self.users
      users = User.count
      if users == 0
        User.anonymous
        User.charlie
        User.loren
      end
    end

    def self.scrub
      return unless Rails.env.development?
      self.empty_tables
      self.reset_auto_increment
    end

    def self.seed
      return unless Rails.env.development?

      self.empty_tables
      Sidekiq.redis do |r|
        r.flushall
      end

      self.reset_auto_increment

      if User.count == 0
        Reader::Setup.users
        Reader::Setup.update_anon_feeds
      end

      users = User.where(:anonymous => false).all
      users.each do |user|
        feed_urls = File.readlines("spec/anon_urls.txt").collect {|line| line}
        #feed_urls = feed_urls.sample 100

        feed_urls.each {|url| user.subscribe(url) }

        subscriptions = Subscription.where(:user_id => user.id).all
        subscriptions.each do |sub|
          groups = Group.where(:user_id => user.id).all
          group = groups.sample
          sub.group = group
          sub.save
        end
      end

      unless User.charlie.nil?
        user = User.charlie

        feed_urls = File.readlines("spec/good_urls.txt").collect {|line| line}
        feed_urls = feed_urls.sample 10

        feed_urls.each {|url|
          user.subscribe(url)
        }

        subscriptions = Subscription.where(:user_id => user.id).all
        subscriptions.each do |sub|
          groups = Group.where(:user_id => user.id).all
          group = groups.sample
          sub.group = group
          sub.save
        end

        grp = Group.find_or_create_by_label_and_user_id "Ruby", user.id
        feed_urls = File.readlines("spec/ruby_urls.txt").collect {|line| line}
        feed_urls.each {|url| user.subscribe(url, grp)}
      end


      bad_urls = File.readlines("spec/failed_urls.txt").collect {|line| line}
      bad_urls = bad_urls.sample(100)
      bad_urls.each do |url|
        Feed.create! :feed_url => url, :name => "Bad URL"
      end

      User.charlie.follow_and_unblock User.loren
      User.loren.follow_and_unblock User.charlie
      User.loren.follow_and_unblock User.josh
      User.josh.follow_and_unblock User.loren
      User.josh.follow_and_unblock User.steve



    end

    def self.reset_auto_increment
      # conn = User.connection
      # conn.tables.each do |t|
      #   conn.execute("select setval('#{t}_id_seq', 1453);")
      # end
    end

    def self.delete_icons
      `rm -rf public/uploads/*`
    end

    def self.empty_tables
      User.delete_all
      Client.delete_all
      Feed.delete_all
      Entry.delete_all
      EntryGuid.delete_all
      Subscription.delete_all
      Category.delete_all
      CategoryEntryMapping.delete_all
      FacebookAuthorization.delete_all
      FeedIcon.delete_all
      Comment.delete_all
      FacebookContact.delete_all
      FetchError.delete_all
      Follow.delete_all
      Group.delete_all
    end

    def self.update_anon_feeds
      user = User.where(:anonymous => true).first

      user.subscriptions.each do |sub|
        sub.destroy
      end
      user.items.each do |item|
        item.delete
      end

      grp = Group.find_or_create_by_label_and_user_id "", user.id

      feed_urls = File.readlines("spec/anon_urls.txt").collect {|line| line}

      feed_urls.each do |fu|
        if fu =~ /^group:/
          grp = Group.find_or_create_by_label_and_user_id fu.sub('group:', ''), user.id
        else
          user.subscribe(url, grp)
        end
      end
    end

    def self.prune_items
      items = Item.where("starred = false AND shared = false AND commented = false").where("created_at < ?", 2.weeks.ago)
      puts "#{items.count} items to delete"
      items.find_each do |i|
        puts "deleting item #{i.id}"
        i.delete
      end
    end

    def self.prune_feeds
      puts "Find feeds without subscriptions"
      Feed.find_each do |f|
        unless f.private
          if f.subscriptions.empty?
            puts "destroy feed #{f.name}"
            f.destroy
          end
        end
      end
    end

    def self.prune_entries
      entries = []
      Entry.find_each do |e|
        if e.items.empty?
          entries << e
        end
      end

      puts "#{entries.length} entries to delete"
      entries.each do |e|
        e.destroy
      end
    end

  end


end
