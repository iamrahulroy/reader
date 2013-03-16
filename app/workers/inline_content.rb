class InlineContent
  include Sidekiq::Worker
  sidekiq_options :queue => :entry
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  attr_accessor :entry

  def perform(id)
    @entry = Entry.find(id)
    return unless @entry.feed_id
    feed_url = @entry.feed.try(:feed_url)
    if feed_url && feed_url =~ /reddit\.com/
      content = @entry.content
      url = @entry.content.match /<a href="([^"]*)">\[link\]/

      imgmatch = url[1].match(/\.(gif|jpg|png|jpeg)(\?|#)*/i) unless url.nil?
      unless imgmatch.nil?
        unless url[1].nil?
          img = "<img src=\"#{url[1]}\" style=\"max-width:95%\"><br/>"
          content = img + @entry.content
        end
      end
      @entry.url = url[1]
      @entry.content = content
    end

    if @entry.url =~ /\/imgur\.com/
      inline_imgur
    end

    if @entry.url =~ /\/qkme\.me/
      inline_quickmeme
    end
    if @entry.url =~ /\/quickmeme\.com/
      inline_quickmeme
    end
    @entry.content_inlined = true
    @entry.save!
  rescue ActiveRecord::RecordNotFound => e
    # sometimes jobs get queued for records that don't exist. WHY?
  end

  def inline_imgur
    doc = Nokogiri::HTML(open(@entry.url))
    images = doc.css(".image img")
    chunk = ""
    images.each do |node|
      node.remove_attribute('class')
      chunk += node.to_s.gsub('data-src', 'src')
    end
    @entry.content = chunk + @entry.content
  end

  def inline_quickmeme
    doc = Nokogiri::HTML(open(@entry.url))
    images = doc.css("#img")
    chunk = ""
    images.each do |node|
      node.remove_attribute('class')
      chunk += node.to_s.gsub('data-src', 'src')
    end
    @entry.content = chunk + @entry.content
  end

  add_transaction_tracer :perform, :category => :task
end