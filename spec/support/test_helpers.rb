module TestHelpers

  #def create_anon_user
  #  anonymous = User.anonymous
  #  unless
  #    u = User.new
  #    u.name = "Anonymous 1kpl.us User"
  #    u.email = "anonymous@1kpl.com"
  #    u.password = '6xsahykygh4tbdmj'
  #    u.password_confirmation = '6xsahykygh4tbdmj'
  #    u.anonymous = true
  #    u.save!
  #  end
  #end

  def create_user
    u = User.new
    u.name = "Gorbles McSheehanstein"
    u.email = "gorbles@example.com"
    u.password = "123123123"
    u.save!
    u.reload
  end

  def create_user_a
    u = User.new
    u.name = "User A"
    u.email = "a@example.com"
    u.password = "123123123"
    u.save!
    u.reload
  end

  def create_user_b
    u = User.new
    u.name = "User B"
    u.email = "b@example.com"
    u.password = "123123123"
    u.save!
    u.reload
  end

  def create_user_c
    u = User.new
    u.name = "User C"
    u.email = "c@example.com"
    u.password = u.password_confirmation = "123123123"
    u.save :validate => false
    u.reload
  end

  def create_anon_feeds
    user = User.anonymous
    grp = Group.find_or_create_by_label_and_user_id "", user.id
    feed_urls = File.readlines("spec/anon_urls.txt").collect {|line| line}

    feed_urls.each do |fu|
      if fu =~ /^group:/
        grp = Group.find_or_create_by_label_and_user_id fu.sub('group:', ''), user.id
      else
        Subscription.find_or_create_from_url_for_user(fu,user,grp)
      end
    end

    run_jobs
    #Feed.fetchable.each do |f|
    #  PollFeed.perform_async(f.id)
    #end
    #GetIcon.drain
  end


  def screenshot
    if Capybara.current_driver == :poltergeist
      page.driver.render(png = "/tmp/poltergeist/#{rand(36**8).to_s(36)}.png")
      x = `open -F #{png}`
    else
      save_and_open_page
    end
  end

  def emails
    ActionMailer::Base.deliveries
  end

  def last_email
    ActionMailer::Base.deliveries.last
  end

  def run_jobs(count = 1)
    sleep 1
    PollFeed.stub(:perform_in)
    #PollFeed.stub(:perform_async)
    #PollFeed.stub(:perform_with_newrelic_transaction_trace)
    #GetIcon.stub(:perform_async)
    count.times do
      Dir["#{Rails.root.to_s}/app/workers/*"].each do |f|
        File.basename(f,'.rb').camelize.constantize.drain
      end
    end
  end

  def clear_jobs
    Dir["#{Rails.root.to_s}/app/workers/*"].each do |f|
      File.basename(f,'.rb').camelize.constantize.jobs.clear
    end
  end

end