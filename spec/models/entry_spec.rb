require 'spec_helper'
describe Entry do
  let(:entry)                { Entry.new guid: "123", url: "http://www.example.com/", feed: feed,
                                             published_at: Date.current }
  let(:feed)                 { Feed.create! name: "Feed 1", feed_url: "http://www.example.com/foo.rss",
                                            site_url: "http://www.example.com/" }

  describe "#inline_youtube" do
    it "should fix the youtube iframes" do
      pending
      entry.content = <<END
<p>What could be better than <em>one</em> Kodie video? <em>Two </em> of course!</p>
<p><span class='embed-youtube' style='text-align:center; display: block;'><iframe class='youtube-player' type='text/html' width='560' height='345' src='http://www.youtube.com/embed/ekgedFwGJDk?version=3&#038;rel=1&#038;fs=1&#038;showsearch=0&#038;showinfo=1&#038;iv_load_policy=1&#038;wmode=transparent' frameborder='0'></iframe></span></p>
<p><span class='embed-youtube' style='text-align:center; display: block;'><iframe class='youtube-player' type='text/html' width='560' height='345' src='http://www.youtube.com/embed/jgQy3f8-Dos?version=3&#038;rel=1&#038;fs=1&#038;showsearch=0&#038;showinfo=1&#038;iv_load_policy=1&#038;wmode=transparent' frameborder='0'></iframe></span></p>
<p>Oh heck- we&#8217;ll just toss <em>these</em> in too.</p>
<p><img class="alignnone size-large wp-image-89279" title="Mmmm Edamame" alt="Almost" src="http://cuteoverload.files.wordpress.com/2013/01/almost.jpg?w=560&#038;h=746" width="560" height="746" /></p>
<p><img class="alignnone size-large wp-image-89281" title="Slight head tilt signals upcoming Baroo" alt="Not Yet" src="http://cuteoverload.files.wordpress.com/2013/01/not-yet.jpg?w=560&#038;h=420" width="560" height="420" /></p>
<p>Angela C. scores again.</p>
<br />Filed under: <a href='http://cuteoverload.com/category/uncategorized/'>Uncategorized</a> Tagged: <a href='http://cuteoverload.com/tag/kodie/'>Kodie</a> <a rel="nofollow" href="http://feeds.wordpress.com/1.0/gocomments/cuteoverload.wordpress.com/89194/"><img alt="" border="0" src="http://feeds.wordpress.com/1.0/comments/cuteoverload.wordpress.com/89194/" /></a> <img alt="" border="0" src="http://stats.wordpress.com/b.gif?host=cuteoverload.com&#038;blog=41949&#038;post=89194&#038;subd=cuteoverload&#038;ref=&#038;feed=1" width="1" height="1" />
END
    end
  end

  describe "#sanitize_content" do
    it "should fix img srcs" do
      pending
      entry.content = <<END
<img class="img-rounded" src="/assets/pages/2662/michael_tubbs_truman_scholar_2011.jpg" alt="michael_tubbs_truman_scholar_2011.jpg" width="200">

<img src="http://boingboing.net/wp-content/uploads/2013/01/Is3uy1.jpg" alt="" title="lockdown" class="size-full wp-image-138212">
END

      puts entry.content
    end
  end

  describe "#save" do
    before :each do
      class PollFeed
        def perform(*args)

        end
      end
    end
    it "should run through the entry post processing steps" do
      PollFeed.stub(:perform => nil)
      entry.save!
      entry.reload.content_inlined.should be_false
      entry.reload.content_embedded.should be_false
      entry.reload.content_sanitized.should be_false
      entry.reload.delivered.should be_false
      entry.reload.processed.should be_false

      run_jobs 1

      entry.reload.content_inlined.should be_true
      run_jobs 1
      entry.reload.content_embedded.should be_true
      run_jobs 1
      entry.reload.content_sanitized.should be_true
      run_jobs 1
      entry.reload.delivered.should be_true
      #run_jobs 1
      entry.reload.processed.should be_true
    end
  end

end