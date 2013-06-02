require 'spec_helper'
describe Entry do
  let(:entry) {
    Entry.new(
      guid: "123",
      url: "http://www.example.com/",
      source_id: feed.id,
      source_type: 'Feed',
      published_at: Date.current,
      content: content
    )
  }

  let(:content) { '' }
  let(:feed) {
    Feed.create!(
      name: "Feed 1",
      feed_url: feed_url,
      site_url: "http://boingboing.net/"
    )
  }

  let(:feed_url) { "http://boingboing.net/foo.rss" }


  describe "#sanitize_content" do
    it "should fix img srcs" do
      entry.content = <<END
<img class="img-rounded" src="/assets/pages/2662/michael_tubbs_truman_scholar_2011.jpg" alt="michael_tubbs_truman_scholar_2011.jpg" width="200">

<img src="http://boingboing.net/wp-content/uploads/2013/01/Is3uy1.jpg" alt="" title="lockdown" class="size-full wp-image-138212">
END

      entry.save!
      entry.content.should include 'src="http://boingboing.net/assets'
    end
  end

  describe "#save" do
    it "creates an entry guid model and updates the reference" do
      entry.save!
      entry.reload.entry_guid.should_not be_nil
      entry_guid = EntryGuid.last
      entry.reload.entry_guid.should == entry_guid
      entry_guid.destroy
      entry.reload.entry_guid.should == nil
      entry.ensure_entry_guid_exists
      entry_guid = EntryGuid.last
      entry.reload.entry_guid.should == entry_guid
    end
  end

  describe '#inline_reddit' do
    context 'when the feed is a reddit feed' do
      let(:feed_url) { 'http://reddit.com/feed.rss' }
    let(:content) {<<-CONTENT
      <table>
      <tr><td>
        <a href="http://www.reddit.com/r/pics/comments/1fimch/im_34_male_and_this_is_my_first_attempt_at_a_cake/">
          <img src="http://f.thumbs.redditmedia.com/Y3vZVxC2BoPWo4BG.jpg" alt="I'm 34, male, and this is my first attempt at a cake for my daughter. Ariel, princess, soccer cake. Was up until 1 ActionMailer." title="I'm 34, male, and this is my first attempt at a cake for my daughter. Ariel, princess, soccer cake. Was up until 1 AM." />
        </a>
      </td>
      <td>
        submitted by <a href="http://www.reddit.com/user/Wonklet"> Wonklet </a>
        <br/>
        #{link}
        <a href="http://www.reddit.com/r/pics/comments/1fimch/im_34_male_and_this_is_my_first_attempt_at_a_cake/">[461 comments]</a>
      </td></tr>
      </table>
    CONTENT
    }

      shared_examples_for 'an embedded image' do
        it 'embeds the image at the top of the content' do
          entry.inline_reddit
          expect(entry.content.lines[0]).to match(
            "<img src=\"#{image}\" style=\"max-width: 95%\"><br/>"
          )
        end
      end

      context 'when link ends with a recognized image file extension' do
        let(:link) { "<a href=\"#{image}\">[link]</a>" }
        let(:image) { 'http://spammy-img.com/hN0vU62.png' }

        it_should_behave_like 'an embedded image'
      end

      context 'when url is to imgur view image page' do
        before do
          entry.stub(
            http_client: stub('HttpClient',
              get: stub('Response',
                body: <<-CONTENT
                  <div id="image" class="image textbox zoom">
                    <div class="">
                        <a href="#{image}">
                        <img src="#{image}" alt="" />
                      </a>
                    </div>
                  </div>
                CONTENT
                )
              )
          )
        end

        let(:link) { '<a href="http://imgur.com/hN0vU62">[link]</a>' }
        let(:image) { 'http://i.imgur.com/hN0vU62.jpg' }

        it_should_behave_like 'an embedded image'
      end
    end
  end
end
